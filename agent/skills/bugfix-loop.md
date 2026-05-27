---
name: bugfix-loop
description: Use when a test or benchmark fails. Diagnoses before patching, applies the minimal fix, and does not silently weaken tests.
---

A test or benchmark failed. Diagnose before patching.

1. Reproduce with the smallest command.
2. Classify the failure:
   - spec error
   - implementation bug
   - test bug
   - environment issue
   - numerical issue
   - invalid research assumption
3. Identify the minimal patch.
4. Explain why the patch is on-path and what it does NOT change.
5. Apply the patch.
6. Re-run the smallest failing test.
7. Re-run broader tests only after the focused test passes.

Hard rules:

- Do not mask the failure.
- Do not change unrelated code.
- Do not silently weaken the test. If the test is genuinely invalid, document
  why in the project's implementation notes.
