#!/usr/bin/env bash
# Regenerate .claude/ and .codex/ discovery trees from the canonical
# sources under agent/agents/ and agent/skills/.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
rm -rf .claude/agents .claude/skills .codex/agents
"$ROOT/agent/bin/agentfw" render-prompts claude . >/dev/null
"$ROOT/agent/bin/agentfw" render-prompts codex . >/dev/null
echo "regenerated .claude/agents, .claude/skills, .codex/agents from agent/"
