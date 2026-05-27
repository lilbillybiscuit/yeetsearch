---
name: drift-check
description: Use at loop boundaries and verification gates.
---

# Skill: drift-check

Use at loop boundaries and verification gates.

1. Load the original `hypothesis.yaml`.
2. Find hypothesis or mechanism restatements in downstream artifacts.
3. Compare each restatement to the original.
4. Flag drift when the restatement no longer entails the original claim.
5. Resolve by reverting the artifact, accepting a formal amendment, or opening a
   new hypothesis.
