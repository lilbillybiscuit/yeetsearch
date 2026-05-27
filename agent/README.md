# Agent Framework

Portable, file-based scaffolding for typed, hash-gated research agents. The
framework is intentionally plain: Markdown prompts, JSON Schemas, YAML/JSONL
templates, and one dependency-free CLI.

## Design Rules

1. Artifacts are typed and frozen by content hash before downstream use.
2. Producer, verifier, and replicator roles are assigned so one role does not
   judge its own output.
3. A claim is not established until a replication report passes from a clean
   environment.

## Layout

- `agents/` - role prompts and file contracts.
- `skills/` - reusable operational checklists.
- `schemas/` - machine-readable artifact schemas.
- `templates/` - starter state-store files.
- `bin/agentfw` - helper CLI for local initialization and checks.
- `tests/` - smoke tests.

## Quick Start

```sh
bin/agentfw init-state /tmp/my-agent-state
bin/agentfw render-prompts codex /tmp/my-prompts/codex
bin/agentfw render-prompts claude /tmp/my-prompts/claude
bin/agentfw inspect-project /path/to/project /tmp/project_snapshot.json
```

## Integration Notes

For Claude Code, use the rendered `.claude/agents` role prompts as subagent
definitions. For Codex CLI, this repository keeps the active agent definitions
in `.codex/agents/*.toml`; use `agent/agents/*.md` as the richer source
contracts when updating them.

The CLI validates local structure and hashes. It does not provide real
container isolation, read-only mounts, or model-family assignment by itself;
those are exposed as explicit fields so a runner can enforce them.
