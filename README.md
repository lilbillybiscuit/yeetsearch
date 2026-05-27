# auto-research-harness

A reusable, domain-neutral multi-agent harness for automated research loops
that run on top of Claude Code and the Codex CLI.

The harness assumes the producer / judge / replicator split is **structural**,
not behavioural: roles route to different model families (Claude vs. Codex),
artifacts are frozen by content hash, and every claim must be reproducible
from an isolated environment before it counts.

## Layout

```
agent/                       Canonical, hand-maintained sources
  agents/                    Markdown source for every agent
  bin/agentfw                Python CLI: init-state, validate, render prompts, hash, smoke
  containers/                Dockerfiles for clean-room replication
  docs/                      Prompt-engineering research notes and rationale
  git-hooks/                 pre-commit + commit-msg hooks enforcing immutability
  schemas/                   JSON schemas for hypothesis, spec, claim, run records
  scripts/                   create_worktree.sh, run_replication.sh, extract_metrics.py, check_harness_setup.sh
  skills/                    Lightweight reusable skills (e.g. claim-ledger-audit)
  templates/agent_state/     Template tree copied into a fresh project's agent_state/
  tests/smoke.sh             Framework-internal smoke test

.claude/agents/              Claude Code discovery files (generated from agent/agents/)
.claude/skills/              Slash-command-style workflow skills (domain-neutral)
.codex/agents/               Codex CLI discovery files (TOML, hand-maintained)
```

`agent_state/` and `worktrees/` are runtime-only and are gitignored. They are
created inside an adopting project, not in this harness repo.

## Install into a project

```bash
# from the root of the target project
cp -a /path/to/auto-research-harness/agent ./
cp -a /path/to/auto-research-harness/.claude/agents .claude/
cp -a /path/to/auto-research-harness/.claude/skills .claude/
cp -a /path/to/auto-research-harness/.codex/agents .codex/

# initialise runtime state
./agent/bin/agentfw init-state .

# verify
bash agent/scripts/check_harness_setup.sh
```

The harness expects the adopting project to provide its own top-level
briefing (`AGENTS.md` and / or `CLAUDE.md`) and any project-specific
session hooks (`.claude/settings.json`). Those are intentionally **not**
shipped here so the harness stays generic.

## Smoke test

```bash
bash agent/scripts/check_harness_setup.sh
```

Should print `harness setup ok`.

## Roles in one line each

- `research-manager` — orchestrates the loop, enforces termination, owns the audit trail.
- `specification` — turns hypotheses into immutable, content-hashed specs with three-tier boundaries.
- `verifier` — cross-family judge; emits a hash-linked "why-trail" verdict.
- `replication` — re-runs the artifact in a clean container; produces an independent claim row.
- `falsifier` — property-based attacker; enumerates attack surfaces and tries to break the claim.
- `triage` — multi-dimensional rubric-based scoring with hard floors.
- `bugfix` — staged Decode → Locate → Plan → Edit + Verify.

See `agent/docs/prompt_research.md` for the prompt-engineering rationale and
sources behind these contracts.

## Status

Bootstrap. The harness is structurally complete; the only validation so far
is the in-repo smoke test. There is no production loop, no published claim,
and no end-to-end run against a real research question yet.
