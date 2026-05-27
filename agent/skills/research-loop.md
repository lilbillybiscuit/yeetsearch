---
name: research-loop
description: Use when running one bounded research iteration. Loads project state, plans a minimal falsifiable artifact, implements, verifies, reviews, and closes the plan. Stops after one iteration unless explicitly told otherwise.
---

Run ONE bounded research iteration. Default `K = 1`. Stop after it.

Follow the project's research-iteration prompt exactly. Key steps:

0. **Challenge the task.** Restate hypothesis in one sentence, list
   assumptions, identify a cheaper falsifying experiment, and run that first
   if it exists.
1. **Load state.** Read the project's problem spec, experiment plan, the
   last few entries of the research log, implementation notes, and the last
   few rows of the experiment ledger, plus any local agent contracts.
2. **Plan the artifact.** Smallest useful: proof sketch / counterexample
   searcher / exact solver for small cases / simulator component / benchmark
   harness / minimal patch. Write a numbered plan with files, tests,
   commands, done criteria.
3. **Implement minimally.** Failing test first → minimal patch → re-run.
4. **Verification gate.** Targeted test passes → compare against an
   independent oracle on small instances → ≥2 workloads or ≥3 repetitions
   for empirical claims → append to the experiment ledger via the project's
   logging script → run the project's results-check script.
5. **Adversarial review.** Delegate to `theory-reviewer`,
   `benchmark-reviewer`, or run the `adversarial-review` skill. Append JSON
   verdict + prose to the project's review log. If `verdict: reject` or any
   `severity: blocking`, stop and report — do not proceed with claims.
6. **Plan closure.** Reconcile every TODO as Done / Blocked / Cancelled in a
   new top entry of the research log.
7. **Report.** Evidence obtained, what's uncertain, decision
   (continue / pivot / stop / ask human), links (commit, ledger row,
   review-log entry).

## Stopping rules (any of)

- Plan closed.
- Same edit→test cycle repeats twice without evidence change.
- Reviewer returns `reject` or any `blocking` issue.
- About to take any ⚠️ "ask first" action from the project's agent contract.
- K iterations completed.

Do not loop "until done."
