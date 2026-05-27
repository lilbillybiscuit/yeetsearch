# Prompt Research Notes

This document records the external prompt-engineering sources consulted to
improve the integrity-critical agents (research-manager, specification,
verifier, replication, falsifier, triage, bugfix). Each section lists the
concrete change applied to the agent's prompt and the source it came from.

Caveat: external prompt advice is heuristic. Where a source's claim was
not independently testable inside this harness, it is recorded as a heuristic
adopted, not a validated improvement.

---

## general-agent-prompting

Improvements applied:

1. Canonical prompts now use explicit sections for role, inputs, outputs,
   tool guidance, forbidden behavior, operating procedure, success criteria,
   escalation, and termination.
2. Thin prompts were expanded with concrete output fields, source IDs,
   artifact paths, and handoff conditions instead of relying on implicit
   shared context.
3. Claude and Codex rendered prompts now both include the common agent
   contract so generated runtimes receive the same universal constraints.
4. Agent prompts prefer compact high-signal context and explicit pointers
   over long summaries, so agents retrieve details just in time.
5. Prompt instructions emphasize structured artifacts, clear boundaries, and
   treating untrusted source text / agent prose as data rather than
   instructions.

Sources:

- OpenAI, "Prompt engineering". Pattern: put high-level behavior, goals,
  constraints, and examples in higher-authority instructions; build evals as
  prompts evolve; GPT-style models benefit from explicit instructions for
  complex tasks.
  <https://developers.openai.com/api/docs/guides/prompt-engineering>
- OpenAI, "Agent definitions". Pattern: an agent packages model,
  instructions, tools, guardrails, handoffs, and structured outputs; keep
  specialist instructions short, concrete, and scoped to a specific task.
  <https://developers.openai.com/api/docs/guides/agents/define-agents>
- OpenAI, "Orchestration and handoffs". Pattern: add specialists only when
  the contract changes; keep routing surfaces narrow and legible; use
  manager-style workflows when the manager owns final synthesis.
  <https://developers.openai.com/api/docs/guides/agents/orchestration>
- Anthropic, "Effective context engineering for AI agents". Pattern: prompts
  should be clear, direct, and at the right altitude; use distinct sections;
  optimize for the smallest high-signal context; prefer just-in-time
  retrieval and structured note-taking for long-horizon work.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- Anthropic, "How we built our multi-agent research system". Pattern:
  subagents need objective, output format, tool/source guidance, and task
  boundaries; scale effort to task complexity; prefer source-quality
  heuristics, parallel exploration, and artifact-backed handoffs.
  <https://www.anthropic.com/engineering/multi-agent-research-system>

---

## ideation-agents

Improvements applied:

1. Brainstorm and boomerang now require mechanism, source IDs, falsifiability,
   information gain, and dead-end checks for every candidate.
2. Boomerang distinguishes the analogy search process from the final
   hypothesis artifact, requiring translation and breakage points.
3. Both ideation agents prefer small high-signal batches over filling quota
   with near-duplicates.

Sources:

- Anthropic, "How we built our multi-agent research system". Pattern: start
  broad, then narrow; encode expert search heuristics rather than brittle
  rules; require clear objective, output format, and task boundaries for
  subagents.
  <https://www.anthropic.com/engineering/multi-agent-research-system>
- Anthropic, "Effective context engineering for AI agents". Pattern: prompts
  should supply enough concrete signals without hardcoding brittle logic.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

---

## retrieval-agents

Improvements applied:

1. Deep-research records source identity, retrieval metadata, exact excerpts,
   source type, reliability notes, and request IDs.
2. Retrieval is explicitly separated from synthesis; conflicts are preserved
   instead of resolved by the retrieval agent.
3. Librarian prompts prioritize compact, source-backed indexes and open
   questions over long pasted context.

Sources:

- Anthropic, "Effective context engineering for AI agents". Pattern:
  just-in-time retrieval, structured notes, and pointers reduce context
  overload in long-horizon agents.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- OpenAI, "Prompt engineering". Pattern: structured outputs and explicit
  instructions reduce ambiguity for downstream consumers.
  <https://developers.openai.com/api/docs/guides/prompt-engineering>

---

## librarian

Improvements applied:

1. Librarian now owns durable context curation: source summaries, reliability
   labels, source-backed claims, conflicts, and open questions.
2. Summaries are optimized as retrievable pointers rather than large context
   dumps.

Sources:

- Anthropic, "Effective context engineering for AI agents". Pattern:
  structured note-taking and small high-signal context are central to
  long-horizon agent reliability.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

---

## baseline

Improvements applied:

1. Baseline now treats every change as a compatibility-preserving migration.
2. Review records require changed paths, compatibility criteria, old-vs-new
   evidence, affected downstream artifacts, and a decision.
3. Conflicted self-approval is forbidden when a claim depends on the affected
   baseline.

Sources:

- OpenAI, "Agent definitions". Pattern: specialist agents should have narrow
  jobs, clear constraints, and structured output when downstream code or
  agents need typed data.
  <https://developers.openai.com/api/docs/guides/agents/define-agents>
- Anthropic, "How we built our multi-agent research system". Pattern:
  artifact-backed handoffs and clear task boundaries prevent coordination
  failures in multi-agent systems.
  <https://www.anthropic.com/engineering/multi-agent-research-system>

---

## experiment

Improvements applied:

1. Experiment now binds every run to spec hash, commit hash, seeds, workloads,
   methods, resources, and metric extraction command before execution.
2. Raw logs are the source of truth; metrics are derived mechanically and never
   hand-authored.
3. Failures are preserved as evidence rather than patched around.

Sources:

- OpenAI, "Prompt engineering". Pattern: explicit instructions and structured
  outputs improve consistency for complex tasks.
  <https://developers.openai.com/api/docs/guides/prompt-engineering>
- Anthropic, "Effective context engineering for AI agents". Pattern: tool
  contracts and context curation matter because tools define the agent's
  interaction boundary with the environment.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

---

## reporting

Improvements applied:

1. Report now requires frontmatter binding to claim, verification,
   replication, and source IDs.
2. Reports must preserve scope, limitations, failed or inconclusive
   hypotheses, and reproducibility pointers.
3. Reporter cannot introduce new claims or upgrade confidence.

Sources:

- OpenAI, "Prompt engineering". Pattern: specify desired outcome, format,
  scope, and constraints explicitly.
  <https://developers.openai.com/api/docs/guides/prompt-engineering>
- Anthropic, "How we built our multi-agent research system". Pattern: final
  outputs should reconcile findings against citations and source quality.
  <https://www.anthropic.com/engineering/multi-agent-research-system>

---

## integration

Improvements applied:

1. Integration now separates verified/replicated evidence from mainline merge
   suitability.
2. Merge proposals require evidence IDs, test preservation, reusable paths,
   scaffolding decisions, and rollback notes.

Sources:

- OpenAI, "Orchestration and handoffs". Pattern: split specialists only when
  capability, policy, output style, or trace legibility changes.
  <https://developers.openai.com/api/docs/guides/agents/orchestration>
- Anthropic, "How we built our multi-agent research system". Pattern:
  multi-agent systems require artifact-backed coordination and outcome-focused
  evaluation rather than trusting a single prose summary.
  <https://www.anthropic.com/engineering/multi-agent-research-system>

---

## resource-allocation

Improvements applied:

1. Resource allocator now treats environment records as evidence-chain
   artifacts.
2. Allocation decisions are `approved`, `queued`, or `refused`, with explicit
   reasons; isolation and mount policy fail closed.

Sources:

- Anthropic, "Effective context engineering for AI agents". Pattern: tools
  form the contract between agents and their environment, so tool boundaries
  and outputs must be clear.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

---

## orchestration

Improvements applied:

1. Orchestrator now binds worktrees to spec hash, mainline commit, hooks, and
   baseline mount policy before implementation starts.
2. Worktree metadata is made audit-friendly so downstream agents do not need
   hidden context.

Sources:

- OpenAI, "Orchestration and handoffs". Pattern: manager-style workflows keep
  one stable owner while specialists perform bounded tasks.
  <https://developers.openai.com/api/docs/guides/agents/orchestration>
- Anthropic, "How we built our multi-agent research system". Pattern: lead
  agents should provide clear boundaries and output contracts to downstream
  workers.
  <https://www.anthropic.com/engineering/multi-agent-research-system>

---

## implementation

Improvements applied:

1. Implementation now emphasizes minimal, spec-bound work and explicit
   amendment requests for ambiguity.
2. The prompt directs the agent to keep context focused on the spec,
   baselines, oracle contracts, and relevant code.
3. Hidden requirements from prior agent prose are rejected in favor of the
   frozen spec.

Sources:

- OpenAI, "Prompt engineering". Pattern: coding prompts benefit from clear
  role definition, structured tool use, and correctness testing expectations.
  <https://developers.openai.com/api/docs/guides/prompt-engineering>
- Anthropic, "Effective context engineering for AI agents". Pattern:
  high-signal context and just-in-time retrieval reduce distraction in complex
  coding tasks.
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

---

## research-manager

Improvements applied:

1. Three independent guardrails (step counter, stall counter, critic
   checkpoint). Gates do not substitute for each other; if one fails, the
   other two still fire.
2. Explicit prohibition on overriding structured verdict fields. The
   manager decides *what to do when stalled*, never *whether a gate
   passed*.
3. Correlation-ID propagation across every dispatch so a single trace can
   be reconstructed from `audit.jsonl`.
4. Audit record schema with monotonic `step` field.

Sources:

- Rajat Pandit, "How LangGraph Supports Cycles (And Preventing Infinite
  Loops)". Pattern: monotonic step counter and periodic Critic node as
  defenses against runaway agent graphs.
  <https://rajatpandit.com/ai-engineering/optimizing-langgraph-cycles>
- Clarion.ai, "Building Multi-Agent Systems: Orchestration Memory And Tool
  Use In Production". Pattern: orchestrator owns termination and recursion
  limit; agents are narrow workers; graph-level contracts, not model-level
  assumptions.
  <https://clarion.ai/insights-building-multi-agent-ai-systems-orchestration-memory-tool-use/>
- AWS, "Build highly scalable serverless LangGraph multi-agent systems".
  Pattern: deterministic graph-based routing for production multi-agent
  systems.
  <https://aws.amazon.com/blogs/machine-learning/build-highly-scalable-serverless-langgraph-multi-agent-systems-in-aws-with-amazon-bedrock-agentcore/>
- Dave Davies, "Best practices for building effective AI agents and
  multi-agent systems" (Online Inference, Apr 2026). Pattern: prompts as
  control plane, observability as day-one requirement.
  <https://medium.com/online-inference/best-practices-for-building-effective-ai-agents-and-multi-agent-systems-2c7fe11c9605>

---

## specification

Improvements applied:

1. Three-tier boundary system (Always / Ask first / Never) added as a
   required spec field. Replaces the implicit ad-hoc list.
2. Explicit `judging` block stating that the judge model family must differ
   from both the implementation and the authoring (specification) model.
3. Spec amendment protocol now requires the new or updated correctness
   test(s) to ride with the amendment.
4. Spec written as an executable contract: every quantitative success
   condition is also a check the verifier can mechanically rerun.

Sources:

- Addy Osmani, "How to write a good spec for AI agents". Pattern: three-tier
  Always / Ask first / Never boundaries; spec as executable artifact.
  <https://addyosmani.com/blog/good-spec/>
- agentcontract/spec on GitHub. Pattern: separate judge model from agent
  being evaluated; structured JSON judge output; deterministic checks
  alongside LLM-judged ones; never silently suppress violations.
  <https://github.com/agentcontract/spec/blob/main/SPEC.md>
- SpecPrompt — "Specs, Not Prompts". Pattern: spec persists, prompts are
  transient; specs in version control with acceptance tests baked in.
  <https://specprompt.com/>
- Snap Engineering, "A Declarative Standard for AI Agents". Pattern:
  declarative agent format, governance by construction, separation of
  agent-owner constraints from organization-wide policy.
  <https://eng.snap.com/agent-format>
- Logic.inc, "How to Build an AI Agent (2026): Prototype to Production
  Guide". Pattern: wrap stochastic model in a deterministic shell with
  immutable, versioned configuration bundles.
  <https://logic.inc/guides/how-to-build-an-ai-agent>

---

## verifier

Improvements applied:

1. Output is a structured "why-trail" with per-check `policy_ref`,
   `source_ref`, observed/expected, and timestamp. No prose verdict.
2. Verification records chain by content hash (`chained_prev_verification_id`)
   for tamper-evidence.
3. Explicit prompt-injection defense: claim text and any other untrusted
   prose must be escaped into a structured field before being passed to a
   sub-judge LLM, never concatenated into the verifier's own prompt.
4. Mandatory ordered checks `c01_*` through `c10_*`; no implicit checks; no
   short-circuit.
5. Different model family from implementation/experiment/bugfix is now
   stated as a hard constraint, not a preference.

Sources:

- MightyBot, "What Is a Policy Engine for AI Agents?". Pattern: every
  decision links to (policy version, source data with pointers, timestamps)
  — the "why-trail".
  <https://mightybot.ai/blog/what-is-a-policy-engine-for-ai-agents/>
- dry-abscess93/proof. Pattern: SHA-256 hash-chained immutable audit
  records; tampering breaks the chain; record links to prior record.
  <https://github.com/dry-abscess93/proof>
- nathanpemberton007-dev/agentapproved-python. Pattern: every event
  hash-chained and signed; LangChain callback handler captures LLM, tool
  use, retrieval events; human oversight recorded inline.
  <https://github.com/nathanpemberton007-dev/agentapproved-python>
- MorkeethHQ/receipt. Pattern: agent cannot pick its own grader; grader
  selected outside the agent's control; signed receipts for each action.
  <https://github.com/MorkeethHQ/receipt>
- Vindicara Project AIR (openpr.com summary). Pattern: causal graph engine
  and counterfactual replay; logs are not evidence; signed records are.
  <https://www.openpr.com/news/4526959/vindicara-launches-project-air-open-source-cryptographic>
- agentcontract/spec on GitHub. Pattern: sanitize agent output before
  inclusion in judge prompts to avoid prompt injection.
  <https://github.com/agentcontract/spec/blob/main/SPEC.md>

---

## replication

Improvements applied:

1. "Quarantine and reseal" protocol named explicitly; the steps are
   numbered and verbatim.
2. `--network=none` (or declared egress proxy with allow-list) is required.
3. Capture `env.json` first, before any build or run.
4. No agent-chosen grader: metric extraction script and tolerance values
   come from the spec, not the replicator.
5. Fail-closed: any inability to satisfy the protocol produces
   `failed_replication`, never a creative workaround.
6. Explicit forbidden list (`git pull`, undocumented build steps, tolerance
   overrides, mounts from the implementation worktree).

Sources:

- Gabriel Anhaia, "Computer-Use Agents: 3 Sandboxing Patterns That Don't
  Leak Credentials" (DEV Community). Pattern: ephemeral container per
  session; credential broker outside the sandbox; egress proxy as the only
  outbound path; agent never holds the secret.
  <https://dev.to/gabrielanhaia/computer-use-agents-3-sandboxing-patterns-that-dont-leak-credentials-4hci>
- Northflank, "How to sandbox AI agents in 2026: MicroVMs, gVisor &
  isolation strategies". Pattern: default to strong isolation; relax only
  when threat model justifies it; containers share host kernel and are
  insufficient for untrusted code on their own.
  <https://northflank.com/blog/how-to-sandbox-ai-agents>
- agentcage/agentcage. Pattern: fail-closed defaults; allow-listed DNS;
  inspecting proxy on every outbound request; placeholders for secrets
  swapped in at the proxy.
  <https://github.com/agentcage/agentcage>
- Addo Zhang, "AI Agent Code Execution Sandboxes". Pattern: trade-offs
  among containers, gVisor, Firecracker, ZeroBoot for sandbox isolation.
  <https://addozhang.medium.com/ai-agent-code-execution-sandboxes-isolation-from-containers-to-microvms-e80848effea5>
- VirtusLab, "Sandboxing LLM coding agents: part1". Pattern: choice between
  Docker, Podman, and microVMs depends on threat model and tooling needs.
  <https://virtuslab.com/blog/ai/sandboxing-llm-coding-agents-part1/>

---

## falsifier

Improvements applied:

1. Five-stage PBT-flavored procedure: Read → Propose properties →
   Generate adversaries → Run + reflect → Confirm + report.
2. Properties grounded in spec invariants and docstrings; not invented
   ad-hoc.
3. Attack-surface table required in the output (`attack_surfaces_enumerated`
   with `coverage` per surface). A `claim_survives` verdict is blocked if
   any row is empty.
4. Callback adversaries: at least one case where an earlier "survived"
   condition is weaponized against a later one (multi-turn pressure).
5. Different model family from implementer and experimenter is a hard
   constraint, not a preference.
6. Counterexample search uses a declared budget; within budget, prefer
   workload IDs disjoint from the experiment matrix.

Sources:

- Maaz, Lipton, et al., "Agentic Property-Based Testing: Finding Bugs
  Across the Python Ecosystem". Pattern: read code/docs → infer properties
  → write Hypothesis tests → run → reflect → confirm; ranking rubric for
  surfacing high-priority bugs.
  <https://arxiv.org/html/2510.09907v1>
- Anthropic, "Property-Based Testing with Claude". Pattern: identify
  properties from type annotations and docstrings; write tests in
  Hypothesis; reflect on whether a failed test is a real bug or a wrong
  property.
  <https://red.anthropic.com/2026/property-based-testing/>
- Dreadnode, "AIRTBench: Do LLM Agents Have AI Red Team Capabilities?".
  Pattern: red-team agents need autonomy and reproducible harnesses.
  <https://dreadnode.io/research/ai-red-team-benchmark/>
- AgentVigil paper (arxiv 2505.05849). Pattern: MCTS-based seed selection
  for adversarial input generation; multi-turn attacks against agent
  systems.
  <https://arxiv.org/html/2505.05849>
- ProofAgent-ai/proofagent-harness. Pattern: jury of three independent
  judges; callbacks across turns; "the third turn under pressure" failure
  mode.
  <https://github.com/ProofAgent-ai/proofagent-harness>

---

## triage

Improvements applied:

1. Per-dimension rubric with `min_pass` and `hard_floor` flags
   (Dimension-Aware Filter). One bad hard-floor dimension fails the
   candidate even if the weighted score is high.
2. Deterministic checks run before LLM scoring (mechanism present,
   falsifiability statement present, not in `known_dead_ends.jsonl`).
3. Scores constrained to integers 0–5; no free-form prose scores.
4. Output is a machine-actionable YAML schema, not a narrative
   recommendation.
5. Pass rule combines `all_hard_floors` with a weighted-score threshold.

Sources:

- iamraghuveer.com, "Building a Reviewer Agent with a Scoring Rubric".
  Pattern: rubric dimensions with per-dimension minimums; overall weighted
  score plus per-dimension floors; route failures back with dimension-linked
  feedback.
  <https://www.iamraghuveer.com/posts/reviewer-agent-scoring-rubric/>
- alphadl/AdaRubrics. Pattern: DimensionAwareFilter — high overall score
  can mask a fatal per-dimension failure; per-dimension minimums are
  necessary.
  <https://github.com/alphadl/adarubrics>
- davegoldblatt/ramsay. Pattern: LLM scores 1–5; code (not the LLM)
  enforces pass/fail; `hard_floor` flag per dimension.
  <https://github.com/davegoldblatt/ramsay>
- DEV Community, "prompt-eval-rubric". Pattern: deterministic rule-based
  checks (regex, length) before LLM judgment to save cost and increase
  consistency.
  <https://dev.to/mukundakatta/prompt-eval-rubric-score-your-agents-outputs-without-paying-for-another-llm-call-4h33>
- DEV Community, "Custom Evals — multi-layer metric system across 17+
  agent frameworks". Pattern: every evaluator declares a DIRECTION;
  thresholds are explicit; ground-truth needs are declared.
  <https://dev.to/anjaiahspr/stop-flying-blind-we-built-an-llm-evaluation-framework-that-works-across-17-agent-frameworks-1698>

---

## bugfix

Improvements applied:

1. Four explicit stages (Decode → Locate → Plan → Edit + Verify) that may
   not be compressed. Compression is the dominant failure mode.
2. Minimal tool set: search, read, single-file edit, test run. Anything
   broader is out of scope.
3. Repetition handling: same proposed patch twice in a row triggers a
   halt.
4. Iteration counter persisted to
   `agent_state/hypotheses/<id>/implementation/bugfix_iterations.txt`;
   budget exhaustion is mechanical.
5. Explicit classification (`code_bug`, `spec_ambiguity`,
   `hypothesis_defect`, `env_documentation_gap`) determines next action.
6. Test weakening is named and forbidden; new tests ride with a spec
   amendment, not a "fix."

Sources:

- Lingxi (lingxi-agent/Lingxi). Pattern: split repair workflow into
  compact, purpose-built agents (Problem Decoder, Solution Mapper, Problem
  Solver, Reviewer) to avoid context dilution; minimal tool set, maximal
  information.
  <https://github.com/lingxi-agent/Lingxi>
- PATCH paper, "Towards Practical and Effective Automatic Program Repair
  with ChatGPT" (arxiv 2501.16149). Pattern: stage-wise framework
  (ChatGPTTester → ChatGPTDeveloper → ChatGPTReviewer); rubber-duck
  debugging in the diagnosis stage.
  <https://arxiv.org/pdf/2501.16149>
- Globant Code Fixer Agent white paper. Pattern: localization stage
  produces a report consumed by Architect → Editor → Critic in the fix
  stage; retry loop on critic dissatisfaction.
  <https://ai.globant.com/wp-content/uploads/2024/12/White-Paper-AI-Agents.pdf>
- sola-st/RepairAgent. Pattern: three states (Understand the bug → Collect
  information → Try fixes); commands_limit and repetition_handling
  parameters; localize → analyze → generate fix → test → iterate.
  <https://github.com/sola-st/RepairAgent>

---

## What we did not adopt

- Cryptographically signed receipts (Ed25519 / ML-DSA / Sigstore Rekor).
  Adopted SHA-256 chained content hashes as the lighter-weight analog;
  signing infrastructure is out of scope until a real claim ledger is
  promoted.
- Firecracker / Kata microVMs. Replication container uses Docker with
  `--network=none` and read-only mounts. MicroVM hardening is an open
  upgrade path documented in `agent/containers/replication.Dockerfile`.
- Jury-of-N voting across multiple judge models. Adopted single
  cross-family verifier and replicator; jury voting is an upgrade path
  for high-stakes claims.
- TEE-attested grader selection (RECEIPT pattern). Cross-family separation
  approximates the property; full TEE attestation is out of scope.

---

## Open questions

- The "claim_survives requires populated attack-surface table" rule needs
  field-testing; some hypotheses may have attack surfaces the falsifier
  cannot meaningfully enumerate in budget, in which case the rule may need
  a `not_applicable` escape with explicit rationale.
- The bugfix agent's "repetition_detected" trip wire is heuristic; needs
  tuning on real failure traces.
- The verifier's content-hash chain is local. Multi-machine reproducibility
  may require a stronger commitment scheme later.
