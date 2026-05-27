#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: agent/scripts/create_worktree.sh <hypothesis_id>" >&2
  exit 2
fi

HYP_ID="$1"
HARNESS_ROOT="$(git rev-parse --show-toplevel)"
BASE_REF="${HARNESS_BASE_REF:-main}"
SPEC_PATH="$HARNESS_ROOT/agent_state/hypotheses/$HYP_ID/spec.yaml"
WORKTREE_PATH="$HARNESS_ROOT/worktrees/$HYP_ID"
BRANCH_NAME="agent/$HYP_ID"

if [[ ! -f "$SPEC_PATH" ]]; then
  echo "Spec not found: $SPEC_PATH" >&2
  exit 1
fi

SPEC_HASH="$(
  python3 - "$SPEC_PATH" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
match = re.search(r"^content_hash:\s*['\"]?([^'\"\n]+)", text, re.MULTILINE)
if not match or match.group(1).strip() in {"", "null"}:
    raise SystemExit("spec missing content_hash")
print(match.group(1).strip())
PY
)"

if [[ -e "$WORKTREE_PATH" ]]; then
  echo "Worktree path already exists: $WORKTREE_PATH" >&2
  exit 1
fi

cd "$HARNESS_ROOT"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_REF"

echo "$SPEC_HASH" > "$WORKTREE_PATH/SPEC_HASH"
echo "$HYP_ID" > "$WORKTREE_PATH/.hyp_id"

mkdir -p "$WORKTREE_PATH/.githooks"
cp "$HARNESS_ROOT/agent/git-hooks/pre-commit" "$WORKTREE_PATH/.githooks/pre-commit"
cp "$HARNESS_ROOT/agent/git-hooks/commit-msg" "$WORKTREE_PATH/.githooks/commit-msg"
chmod +x "$WORKTREE_PATH/.githooks/pre-commit" "$WORKTREE_PATH/.githooks/commit-msg"

(
  cd "$WORKTREE_PATH"
  git config core.hooksPath .githooks
  if [[ ! -e baselines ]]; then
    ln -s "$HARNESS_ROOT/agent/baselines" baselines
  fi
  git add SPEC_HASH .hyp_id
  HARNESS_ALLOW_INITIALIZE=1 git commit -m "[$HYP_ID] initialize harness worktree with spec hash $SPEC_HASH"
)

mkdir -p "$HARNESS_ROOT/agent_state/hypotheses/$HYP_ID/implementation"
printf '%s\n' "$WORKTREE_PATH" > "$HARNESS_ROOT/agent_state/hypotheses/$HYP_ID/implementation/worktree_path"

printf '%s\n' "$WORKTREE_PATH"
