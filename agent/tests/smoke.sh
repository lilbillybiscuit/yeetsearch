#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$ROOT/.." && pwd)"
WORK="$(mktemp -d)"
STATE="$WORK/agent_state"
trap 'rm -rf "$WORK"' EXIT

chmod +x "$ROOT/bin/agentfw"

"$ROOT/bin/agentfw" validate-framework >/tmp/agentfw-validate.json
"$ROOT/bin/agentfw" init-state "$STATE" >/tmp/agentfw-init.txt
test -f "$STATE/index/hypotheses.jsonl"
test -f "$STATE/hypotheses/hyp_template/spec.yaml"

ART="$WORK/freeze-test.txt"
printf 'frozen artifact\n' > "$ART"
"$ROOT/bin/agentfw" freeze-artifact "$ART" >/tmp/agentfw-freeze.txt
"$ROOT/bin/agentfw" verify-artifact "$ART" >/tmp/agentfw-verify-ok.json
chmod u+w "$ART"
printf 'mutation\n' >> "$ART"
if "$ROOT/bin/agentfw" verify-artifact "$ART" >/tmp/agentfw-verify-bad.json; then
  echo "expected hash verification to fail after mutation" >&2
  exit 1
fi

"$ROOT/bin/agentfw" inspect-project "$PROJECT_ROOT" "$WORK/project_snapshot.json" >/tmp/agentfw-inspect.txt
python3 -m json.tool "$WORK/project_snapshot.json" >/tmp/agentfw-snapshot-valid.json
grep -q '"AGENTS.md"' "$WORK/project_snapshot.json"

"$ROOT/bin/agentfw" render-prompts codex "$WORK/prompts/codex" >/tmp/agentfw-render-codex.txt
"$ROOT/bin/agentfw" render-prompts claude "$WORK/prompts/claude" >/tmp/agentfw-render-claude.txt

# common-contract is not an agent, must not be rendered as one.
test ! -e "$WORK/prompts/claude/.claude/agents/common-contract.md"
test ! -e "$WORK/prompts/codex/.codex/agents/common-contract.toml"

# Both bundles must expose the same agent roster (parity check).
claude_names="$(cd "$WORK/prompts/claude/.claude/agents" && ls *.md | sed 's/\.md$//' | sort)"
codex_names="$(cd "$WORK/prompts/codex/.codex/agents" && ls *.toml | sed 's/\.toml$//' | sort)"
if [[ "$claude_names" != "$codex_names" ]]; then
  echo "agent roster mismatch between claude and codex" >&2
  diff <(echo "$claude_names") <(echo "$codex_names") >&2 || true
  exit 1
fi

# Spot-check that integrity-critical agents appear in both bundles.
for name in research-manager specification verifier replication falsifier triage bugfix; do
  test -f "$WORK/prompts/claude/.claude/agents/$name.md"
  test -f "$WORK/prompts/codex/.codex/agents/$name.toml"
done

# Every next_agent in the dispatch table must exist in both generated rosters.
python3 - "$ROOT/dispatch.yaml" "$WORK/prompts/claude/.claude/agents" "$WORK/prompts/codex/.codex/agents" <<'PY'
import re
import sys
from pathlib import Path

dispatch_path = Path(sys.argv[1])
claude_dir = Path(sys.argv[2])
codex_dir = Path(sys.argv[3])

agents = sorted(set(re.findall(r"^\s*next_agent:\s*([A-Za-z0-9_-]+)\s*$", dispatch_path.read_text(), re.MULTILINE)))
missing = []
for agent in agents:
    if not (claude_dir / f"{agent}.md").exists():
        missing.append(f"claude:{agent}")
    if not (codex_dir / f"{agent}.toml").exists():
        missing.append(f"codex:{agent}")
if missing:
    print("dispatch references missing agents:", ", ".join(missing), file=sys.stderr)
    sys.exit(1)
PY

# Every codex toml must declare model = "gpt-5.5".
python3 - "$WORK/prompts/codex/.codex/agents" <<'PY'
import sys, tomllib
from pathlib import Path

agents_dir = Path(sys.argv[1])
bad = []
for path in sorted(agents_dir.glob("*.toml")):
    data = tomllib.loads(path.read_text())
    if data.get("model") != "gpt-5.5":
        bad.append((path.name, data.get("model")))
    if data.get("name") != path.stem:
        bad.append((path.name, "name mismatch"))
    if data.get("sandbox_mode") not in {"read-only", "workspace-write"}:
        bad.append((path.name, data.get("sandbox_mode")))
    if not data.get("developer_instructions", "").strip():
        bad.append((path.name, "empty instructions"))
if bad:
    print("codex toml problems:", bad, file=sys.stderr)
    sys.exit(1)
PY

# Skills should render from the remaining canonical skill sources.
test -f "$WORK/prompts/claude/.claude/skills/artifact-freeze/SKILL.md"

echo "smoke ok"
