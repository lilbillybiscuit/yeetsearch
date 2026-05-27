# Common Agent Contract

Every agent operates on artifacts, not prose summaries. Anything not explicitly
listed in an agent's write contract is forbidden.

## Required Sections

- Role
- Model family constraint
- System prompt / instructions
- Inputs (read)
- Outputs (write)
- Tools allowed
- Tools forbidden
- Operating procedure
- Success conditions
- Failure / escalation
- Hard constraints
- Termination

## Universal Hard Constraints

- Do not edit frozen artifacts in place.
- Do not verify, replicate, or promote artifacts produced by the same role.
- Do not write quantitative claims unless they trace to `agent_state/index/claims.jsonl`.
- Do not modify `baselines/` unless acting as the baseline agent.
- Write failures as artifacts with reproduction details.
