#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: agent/scripts/run_replication.sh <hypothesis_id> <claim_id>" >&2
  exit 2
fi

HYP_ID="$1"
CLAIM_ID="$2"
HARNESS_ROOT="$(git rev-parse --show-toplevel)"
CLAIMS_PATH="$HARNESS_ROOT/agent_state/index/claims.jsonl"
REPLICATION_ROOT="$HARNESS_ROOT/agent_state/hypotheses/$HYP_ID/replications"
REPLICATION_ID="rep_$(date -u +%Y%m%dT%H%M%SZ)_$$"
OUTPUT_DIR="$REPLICATION_ROOT/$REPLICATION_ID"
IMAGE="${HARNESS_REPLICATION_IMAGE:-research-replication:latest}"
NETWORK="${HARNESS_REPLICATION_NETWORK:-none}"
REPO_URL="${HARNESS_REPLICATION_REPO_URL:-$(git config --get remote.origin.url)}"
AGENT_TOML="$HARNESS_ROOT/.codex/agents/replication.toml"

if [[ ! -f "$CLAIMS_PATH" ]]; then
  echo "Claim ledger not found: $CLAIMS_PATH" >&2
  exit 1
fi

if [[ ! -f "$AGENT_TOML" ]]; then
  echo "Replication agent prompt not found: $AGENT_TOML" >&2
  exit 1
fi

if [[ -z "$REPO_URL" ]]; then
  echo "Replication repo URL unavailable; set HARNESS_REPLICATION_REPO_URL" >&2
  exit 1
fi

COMMIT_HASH="$(
  python3 - "$CLAIMS_PATH" "$CLAIM_ID" <<'PY'
import json
import sys

claims_path, claim_id = sys.argv[1], sys.argv[2]
with open(claims_path, "r", encoding="utf-8") as handle:
    for line in handle:
        line = line.strip()
        if not line:
            continue
        claim = json.loads(line)
        if claim.get("claim_id") != claim_id:
            continue
        for key in ("git_commit", "implementation_commit", "commit_hash"):
            if claim.get(key):
                print(claim[key])
                raise SystemExit(0)
        raise SystemExit(f"claim {claim_id} has no commit hash field")
raise SystemExit(f"claim not found: {claim_id}")
PY
)"

mkdir -p "$OUTPUT_DIR"

docker run --rm \
  --name "replication-$REPLICATION_ID" \
  --network="$NETWORK" \
  --mount type=bind,src="$HARNESS_ROOT/agent_state",dst=/agent_state,ro \
  --mount type=bind,src="$OUTPUT_DIR",dst=/output \
  --mount type=bind,src="$HARNESS_ROOT/agent/baselines",dst=/baselines,ro \
  --mount type=bind,src="$AGENT_TOML",dst=/replication-agent.toml,ro \
  --env HYP_ID="$HYP_ID" \
  --env CLAIM_ID="$CLAIM_ID" \
  --env COMMIT_HASH="$COMMIT_HASH" \
  --env REPLICATION_ID="$REPLICATION_ID" \
  --env REPO_URL="$REPO_URL" \
  "$IMAGE" \
  bash -lc 'python3 - <<'"'"'PY'"'"' | codex -a never exec -C /workspace -s workspace-write -
import os
import tomllib
from pathlib import Path

data = tomllib.loads(Path("/replication-agent.toml").read_text())
print(data["developer_instructions"])
print()
print(
    "Task: Replicate claim {claim_id} for {hyp_id}. "
    "Clone repository {repo_url} at commit {commit_hash}. "
    "Use /agent_state and /baselines as read-only inputs. "
    "Write report.yaml, run.jsonl, stdout.log, stderr.log, and env.json to /output. "
    "Replication ID: {replication_id}."
    .format(
        claim_id=os.environ["CLAIM_ID"],
        hyp_id=os.environ["HYP_ID"],
        repo_url=os.environ["REPO_URL"],
        commit_hash=os.environ["COMMIT_HASH"],
        replication_id=os.environ["REPLICATION_ID"],
    )
)
PY'
