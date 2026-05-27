#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [[ ! -d "agent_state" ]]; then
  echo "agent_state/ missing; bootstrapping from agent/templates/agent_state ..." >&2
  mkdir -p agent_state
  "$ROOT/agent/bin/agentfw" init-state agent_state
fi

required_files=(
  "agent_state/index/hypotheses.jsonl"
  "agent_state/index/claims.jsonl"
  "agent_state/index/known_dead_ends.jsonl"
  "agent/scripts/create_worktree.sh"
  "agent/scripts/run_replication.sh"
  "agent/scripts/extract_metrics.py"
  "agent/git-hooks/pre-commit"
  "agent/git-hooks/commit-msg"
  "agent/containers/replication.Dockerfile"
  "agent/bin/agentfw"
  "agent/agents/common-contract.md"
)

# Every non-common agent under agent/agents/ must have a Claude .md and a
# Codex .toml mirror, both freshly rendered from the canonical source.
for src in agent/agents/*.md; do
  name="$(basename "$src" .md)"
  [[ "$name" == "common-contract" ]] && continue
  required_files+=(".claude/agents/$name.md" ".codex/agents/$name.toml")
done

# Every skill under agent/skills/ must have a Claude SKILL.md mirror.
for src in agent/skills/*.md; do
  name="$(basename "$src" .md)"
  required_files+=(".claude/skills/$name/SKILL.md")
done

for path in "${required_files[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "missing required harness file: $path" >&2
    exit 1
  fi
done

executable_files=(
  "agent/scripts/create_worktree.sh"
  "agent/scripts/run_replication.sh"
  "agent/scripts/extract_metrics.py"
  "agent/scripts/check_harness_setup.sh"
  "agent/git-hooks/pre-commit"
  "agent/git-hooks/commit-msg"
  "agent/bin/agentfw"
)

for path in "${executable_files[@]}"; do
  if [[ ! -x "$path" ]]; then
    echo "required file is not executable: $path" >&2
    exit 1
  fi
done

bash -n \
  agent/scripts/create_worktree.sh \
  agent/scripts/run_replication.sh \
  agent/scripts/check_harness_setup.sh \
  agent/git-hooks/pre-commit \
  agent/git-hooks/commit-msg

python3 -m py_compile agent/scripts/extract_metrics.py agent/bin/agentfw

python3 - <<'PY'
import tomllib
from pathlib import Path

for path in sorted(Path(".codex/agents").glob("*.toml")):
    tomllib.loads(path.read_text())
PY

"$ROOT/agent/bin/agentfw" validate-framework >/tmp/agentfw-validate.json
bash "$ROOT/agent/tests/smoke.sh" >/tmp/agentfw-smoke.txt

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
run_jsonl="$tmpdir/run.jsonl"
metrics_jsonl="$tmpdir/metrics.jsonl"
cat > "$run_jsonl" <<'JSONL'
{"event":"run_start","hypothesis_id":"hyp_smoke","experiment_id":"exp_smoke","spec_hash":"sha256:smoke","git_commit":"0000000"}
{"event":"measurement","hypothesis_id":"hyp_smoke","experiment_id":"exp_smoke","seed":0,"workload_id":"tiny","method":"candidate","metric":"runtime_seconds","value":1.0}
{"event":"measurement","hypothesis_id":"hyp_smoke","experiment_id":"exp_smoke","seed":1,"workload_id":"tiny","method":"candidate","metric":"runtime_seconds","value":3.0}
{"event":"run_end","hypothesis_id":"hyp_smoke","experiment_id":"exp_smoke","exit_code":0,"duration_seconds":4}
JSONL
python3 agent/scripts/extract_metrics.py "$run_jsonl" "$metrics_jsonl"
python3 - "$metrics_jsonl" <<'PY'
import json
import sys

records = [json.loads(line) for line in open(sys.argv[1], encoding="utf-8")]
metrics = [record for record in records if record["event"] == "metric"]
assert len(metrics) == 1, metrics
assert metrics[0]["mean"] == 2.0, metrics[0]
PY

echo "harness setup ok"
