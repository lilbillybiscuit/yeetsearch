---
name: benchmark-review
description: Use before accepting a benchmark result or speedup claim. Reviews benchmark validity, baseline fairness, reproducibility, and noise.
---

Act as a systems benchmark reviewer.

Check:

1. Does the benchmark measure the claimed mechanism (not something else)?
2. Is the baseline fair? Same hardware, same workload, same parameters,
   same compiler/runtime flags, same parallelism settings?
3. Are commands, configs, seeds, and commit hash recorded?
4. Is the result reproducible from the project's experiment ledger?
5. Could the speedup come from noise, caching, a bug, or skipped work?
6. Were there enough repetitions to support the claim? Was variance reported?
7. Should the claim be weakened to "preliminary" or "single-run"?

Require: commands, configs, seeds, commit hash, raw outputs.

Append the result to the project's review log.
