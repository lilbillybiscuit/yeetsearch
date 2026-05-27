# AGENTS.md — auto-research-harness

This repository is the standalone, domain-neutral version of the
auto-research harness. It does not run research against any specific
problem; it is the source bundle that adopting projects copy into place.

## Single source of truth

- `agent/agents/<name>.md` — canonical contract for one agent.
- `agent/skills/<name>.md` — canonical contract for one skill.

`.claude/agents/`, `.claude/skills/`, and `.codex/agents/` are **generated**
from those sources by `agent/bin/agentfw render-prompts`. Treat them as
build output, not source.

To regenerate after editing anything in `agent/agents/` or `agent/skills/`:

```bash
bash agent/scripts/regenerate_discovery.sh
```

## Boundaries

### Always
- Run `bash agent/scripts/check_harness_setup.sh` after any change to an
  agent contract, skill, schema, script, or hook. It must print
  `harness setup ok`.
- Keep every prompt generic. No domain-specific terms, no references to
  workloads from any adopting project.
- Make Claude and Codex render the same roster. The smoke test enforces
  agent-set parity.
- Treat `agent/templates/agent_state/` as the seed copied by `init-state`.
  Do not edit live `agent_state/` from inside this repo.

### Ask first
- Adding a new agent contract or skill.
- Renaming an existing agent or changing the role's "produce / judge /
  replicate" assignment.
- Changing the Codex default model (`CODEX_MODEL` in `agent/bin/agentfw`)
  or sandbox overrides (`CODEX_SANDBOX_OVERRIDES`).
- Introducing a new dependency to `agent/bin/agentfw`.

### Never
- Hand-edit anything under `.claude/agents/`, `.claude/skills/`, or
  `.codex/agents/`. They are regenerated; changes will be lost.
- Reintroduce domain-specific language to prompts under `agent/agents/` or
  `agent/skills/`.
- Commit anything under `agent_state/` or `worktrees/`. They are
  gitignored on purpose.

## Done means

- Smoke test passes.
- No new domain-specific tokens reintroduced
  (`rg -i "k-clique|kclique|Pivoter|gbbs|CPPImpl"` returns no hits in
  `agent/`, `.claude/`, `.codex/`).
- `.claude/` and `.codex/` are in sync with `agent/` (run
  `bash agent/scripts/regenerate_discovery.sh` and commit the diff).
- README and this file still accurately describe the layout.
