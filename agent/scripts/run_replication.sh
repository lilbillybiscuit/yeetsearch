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

if [[ ! -f "$CLAIMS_PATH" ]]; then
  echo "Claim ledger not found: $CLAIMS_PATH" >&2
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
  --network=none \
  --mount type=bind,src="$HARNESS_ROOT/agent_state",dst=/agent_state,ro \
  --mount type=bind,src="$OUTPUT_DIR",dst=/output \
  --mount type=bind,src="$HARNESS_ROOT/agent/baselines",dst=/baselines,ro \
  --env HYP_ID="$HYP_ID" \
  --env CLAIM_ID="$CLAIM_ID" \
  --env COMMIT_HASH="$COMMIT_HASH" \
  --env REPLICATION_ID="$REPLICATION_ID" \
  "$IMAGE" \
  codex --agent replication --headless \
    --message "Replicate claim $CLAIM_ID for $HYP_ID. Commit hash $COMMIT_HASH. Write report to /output/report.yaml."
