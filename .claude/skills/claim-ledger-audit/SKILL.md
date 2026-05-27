---
name: claim-ledger-audit
description: Use when writing or verifying any report with claims.
---

# Skill: claim-ledger-audit

Use when writing or verifying any report with claims.

1. Split the text into atomic quantitative or qualitative claims.
2. For each claim, locate a matching entry in `agent_state/index/claims.jsonl`.
3. Confirm `evidence_refs`, `verifier_id`, and `replication_id` exist.
4. Reject unledgered numbers or comparative statements.
5. Preserve the scope from the ledger when writing prose.
