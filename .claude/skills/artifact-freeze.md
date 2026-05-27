# Skill: artifact-freeze

Use when creating any artifact consumed by another agent.

1. Write the artifact once.
2. Validate its schema.
3. Compute a SHA-256 content hash.
4. Store the hash beside the artifact or in the parent status record.
5. Treat any later hash mismatch as mutation, not a harmless edit.

Frozen artifacts are append-only by replacement protocol: create an amendment or
new artifact, never edit the original in place.
