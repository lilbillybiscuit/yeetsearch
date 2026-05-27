---
name: clean-replication
description: Use for replication agent runs.
---

# Skill: clean-replication

Use for replication agent runs.

1. Start a fresh environment with no implementation worktree mount.
2. Clone by logged commit hash.
3. Build using only documented commands.
4. Execute the documented run command verbatim.
5. Capture stdout, stderr, env, exit code, and duration.
6. Run the declared extraction script.
7. Compare with the claim using the declared tolerance.
8. Run correctness tests.

Undocumented setup is a replication failure.
