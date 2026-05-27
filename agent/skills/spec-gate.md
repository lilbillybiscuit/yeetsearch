# Skill: spec-gate

Use before allocating implementation work.

Required checks:

- `hypothesis_id`
- `hypothesis_hash`
- `mechanism`
- `minimal_implementation.what_must_exist`
- `minimal_implementation.what_must_not_exist`
- `correctness_criteria`
- `baselines`
- `evaluation.primary_metric`
- `evaluation.metric_extraction`
- `evaluation.seeds`
- `evaluation.significance_test`
- `evaluation.workloads`
- `required_resources`
- `success_condition`
- `failure_condition`
- `inconclusive_condition`
- `expected_failure_modes`
- `budgets`

Reject incomplete specs before any worktree is created.
