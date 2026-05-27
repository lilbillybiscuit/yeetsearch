# AGENTS.md — auto-research-harness

This repository is the standalone, domain-neutral version of the
auto-research harness. It does not run research against any specific
problem; it is the source bundle that adopting projects copy into place.

## Scope

- `agent/` is the canonical source of every agent contract, schema,
  template, and script. Edit here.
- `.claude/agents/` is regenerated from `agent/agents/` via
  `agent/bin/agentfw render-prompts claude .claude`. Do not hand-edit.
- `.claude/skills/` is hand-maintained, domain-neutral slash-command
  workflows.
- `.codex/agents/*.toml` is hand-maintained; mirror any contract changes
  from `agent/agents/*.md` manually.

## Boundaries

### Always
- Run `bash agent/scripts/check_harness_setup.sh` after touching any
  agent contract, schema, script, or hook. It must print
  `harness setup ok`.
- Keep prompts generic. No domain-specific terms, no references to
  workloads from any adopting project.
- Treat `agent/templates/agent_state/` as the seed copied by `init-state`.
  Do not edit live `agent_state/` from inside this repo.

### Ask first
- Adding a new agent contract.
- Renaming an existing agent or changing the role's "produce / judge /
  replicate" assignment.
- Introducing a new dependency to `agent/bin/agentfw`.

### Never
- Reintroduce domain-specific language to prompts under `agent/agents/`,
  `.claude/agents/`, `.claude/skills/`, or `.codex/agents/`.
- Hand-edit files under `.claude/agents/` that were rendered from
  `agent/agents/`.
- Commit anything under `agent_state/` or `worktrees/`. They are
  gitignored on purpose.

## Done means

- Smoke test passes.
- No new domain-specific tokens reintroduced
  (`rg -i "k-clique|kclique|Pivoter|gbbs|CPPImpl"` returns no hits in
  `agent/`, `.claude/`, `.codex/`).
- README and this file still accurately describe the layout.
