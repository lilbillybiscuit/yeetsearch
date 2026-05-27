---
name: optimization-pass
description: Use to optimize hot paths AFTER correctness is established. Requires baseline, mechanism hypothesis, and repeated measurement.
---

Optimize only if correctness is already established.

Before editing:

1. Show profiling or benchmark evidence for the bottleneck.
2. State the baseline metric and exact command/config.
3. State the optimization hypothesis (mechanism, not vibe).
4. State correctness risks.
5. State the benchmark command (exact).

Then make ONE optimization only.

After editing:

1. Run correctness tests, including independent-oracle comparison on small instances.
2. Run benchmark with the SAME config as the baseline.
3. Compare against baseline (multiple runs; report median + spread).
4. Keep or revert based on evidence.
5. Log results to the project's experiment ledger with a clear `baseline` field.

Hard rules:

- One optimization at a time.
- No correctness regressions, ever.
- Speedup claims require >1 run and a named baseline.
- Cold/warm cache effects must be controlled for or disclosed.
