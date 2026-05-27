# auto-research-harness

A reusable, domain-neutral multi-agent harness for automated research loops
that run on top of Claude Code and the Codex CLI.

The harness assumes the producer / judge / replicator split is **structural**,
not behavioural: roles route to different model families (Claude vs. Codex),
artifacts are frozen by content hash, and every claim must be reproducible
from an isolated environment before it counts.

## Single source of truth

Everything an agent or skill does is defined once, under `agent/`:

- `agent/agents/<name>.md` — canonical Markdown contract for one agent.
- `agent/skills/<name>.md` — canonical Markdown for one skill.

The CLI-specific discovery trees are **generated** from those sources:

- `.claude/agents/<name>.md` — one file per agent (every agent in `agent/agents/` except `common-contract`).
- `.claude/skills/<name>/SKILL.md` — one directory per skill.
- `.codex/agents/<name>.toml` — one file per agent, mirroring the Claude roster, with `model = "gpt-5.5"` and `sandbox_mode` set per agent.

Both Claude Code and the Codex CLI see the **same agent roster**. The smoke
test enforces parity.

Regenerate the discovery trees any time `agent/agents/` or `agent/skills/`
changes:

```bash
bash agent/scripts/regenerate_discovery.sh
```

Do not hand-edit anything under `.claude/agents/`, `.claude/skills/`, or
`.codex/agents/`. Changes there will be overwritten on next regeneration.

## Layout

```
agent/
  agents/                    Canonical Markdown contracts (one file per agent)
    common-contract.md       Shared preamble prepended into every Codex agent's instructions
  skills/                    Canonical Markdown skills (one file per skill)
  bin/agentfw                Python CLI: init-state, validate, render-prompts, hash, smoke
  containers/                Dockerfiles for clean-room replication
  docs/                      Prompt-engineering research notes
  git-hooks/                 pre-commit + commit-msg hooks enforcing immutability
  schemas/                   JSON schemas for hypothesis, spec, claim, run records
  scripts/                   Worktree setup, replication driver, metric extractor, smoke check, regenerate script
  templates/agent_state/     Seed tree copied by `agentfw init-state`
  tests/smoke.sh             Framework-internal smoke test

.claude/agents/              Generated: Claude Code discovery files
.claude/skills/              Generated: Claude Code skill files
.codex/agents/               Generated: Codex CLI TOML discovery files (model = "gpt-5.5")
```

`agent_state/` and `worktrees/` are runtime-only and gitignored.

## Install into a project

```bash
# from the root of the target project
cp -a /path/to/auto-research-harness/agent ./
cp -a /path/to/auto-research-harness/.claude ./
cp -a /path/to/auto-research-harness/.codex ./

# initialise runtime state
mkdir -p agent_state
./agent/bin/agentfw init-state agent_state

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

Should print `harness setup ok`. The check auto-bootstraps `agent_state/`
from the template if it is missing, then verifies:

- every agent in `agent/agents/` (except `common-contract`) has both a Claude `.md` and a Codex `.toml`,
- every skill in `agent/skills/` has a Claude `SKILL.md`,
- every Codex `.toml` parses and declares `model = "gpt-5.5"`,
- the Claude and Codex agent rosters match exactly.

## Roles in one line each

- `research-manager` — orchestrates the loop, enforces termination, owns the audit trail.
- `specification` — turns hypotheses into immutable, content-hashed specs with three-tier boundaries.
- `implementation` — produces the candidate artifact (code, proof, design) on a worktree.
- `experiment` — runs the artifact under the declared workload and produces raw `run.jsonl`.
- `verifier` — cross-family judge; emits a hash-linked "why-trail" verdict. Codex sandbox: read-only.
- `replication` — re-runs the artifact in a clean container; produces an independent claim row.
- `falsifier` — property-based attacker; enumerates attack surfaces and tries to break the claim.
- `triage` — multi-dimensional rubric-based scoring with hard floors. Codex sandbox: read-only.
- `bugfix` — staged Decode → Locate → Plan → Edit + Verify.
- `brainstorm`, `librarian`, `deep-research`, `baseline`, `report`, `integration`, `resource-allocator`, `orchestrator`, `boomerang` — supporting roles around the core loop.

See `agent/docs/prompt_research.md` for the prompt-engineering rationale and
sources behind these contracts.

## Status

Bootstrap. The harness is structurally complete; the only validation so far
is the in-repo smoke test. There is no production loop, no published claim,
and no end-to-end run against a real research question yet.
