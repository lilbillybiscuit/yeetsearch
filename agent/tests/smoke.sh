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
test -f "$WORK/prompts/codex/AGENTS.generated.md"
# Claude bundle should contain a Claude-family agent (research-manager) and
# should NOT contain Codex-family agents (verifier, falsifier, replication,
# triage, bugfix) or non-agent template files (common-contract).
test -f "$WORK/prompts/claude/.claude/agents/research-manager.md"
for skip in verifier falsifier replication triage bugfix common-contract; do
  test ! -e "$WORK/prompts/claude/.claude/agents/$skip.md"
done
test ! -e "$WORK/prompts/claude/.claude/agents/other-roles.md"

echo "smoke ok"
