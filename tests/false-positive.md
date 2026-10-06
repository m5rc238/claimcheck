# Test: false positive

**Purpose.** A plausible objection is generated, tested, and rejected because the
evidence does not support it. The claim survives.

**The failure this catches.** The characteristic error of a red-team evaluator:
treating a plausible methodological concern as a demonstrated defect. The
characteristic symptom is `decision_impact: revise` on an objection whose
`supporting_evidence` is empty.

**What this test does not establish.** That the protocol does not produce false
positives in general. One hand-built case, one claim, and no ground truth about
whether the objection really was unfounded. See
`evaluator_error_rate_not_determinable` below.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The migration to Postgres reduced p99 checkout latency by 40%."

**Supplied.** `benchmark-results.md`, `change-notes.md`, `harness-doc.md`.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `decision_impact` |
| --- | --- | --- | --- | --- |
| O1 benchmark path differs from production | `contradicted` | `demonstrated` | `no_demonstrated_problem` | `no_effect` |
| O2 a 40% reduction is too large to be real | `unsupported` | `possible` | `meaningful_risk` | `no_effect` |

Overall: **`retain`** — and the statement must not assert validation.

## Pass criteria

1. At least one plausible objection is generated. Zero objections is not a pass;
   it means the audit did not attempt to find problems.
2. No objection has `status: supported`.
3. No objection has a non-empty `supporting_evidence`.
4. Overall result is `retain`.
5. The overall statement contains no validation language (`schema.md` R12).
6. The rejected objections remain on the record with their status, rather than
   being dropped.

## Record

```yaml
claim:
  original: "The migration to Postgres reduced p99 checkout latency by 40%."
  subject: Postgres migration
  predicate: reduced p99 checkout latency by 40%
  scope: the checkout request path as measured by the supplied benchmark
  population: checkout requests in the benchmark environment
  timeframe: benchmark runs documented in benchmark-results.md
  baseline: pre-migration checkout latency from the same harness
  intended_interpretation: a measured performance improvement
  dependent_decision: whether to complete the rollout to remaining services
  missing_definitions:
    - "the benchmark environment is not described in relation to production"
  load_bearing_assumptions:
    - "the harness measures the same code path as production"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the measured 40% reduction is a real measurement of the checkout path"
  out_of_scope:
    - "latency on paths other than checkout"
    - "production traffic behaviour"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "benchmark-results.md section 2"
      content: "p99 checkout latency fell from 840ms to 502ms, a 40.2% reduction, across five benchmark runs."
    - ref: E2
      type: document
      locator: "harness-doc.md section 1"
      content: "The harness exercises the production checkout service against a staging Postgres cluster using production query plans; no stubbed or cached data layer is used."
    - ref: E3
      type: document
      locator: "change-notes.md section 3"
      content: "No code change other than the datastore migration was deployed in the measured window."
  unavailable_evidence:
    - "production p99 latency, which was not measured"
    - "a pre-registered benchmark protocol"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O1, the harness-fidelity concern"
      - "O2, the implausible-magnitude concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "Benchmarks routinely diverge from production, so the 40% reduction is a harness artefact rather than a real gain."
    why_it_might_matter: "If the harness is not measuring the production path, the rollout decision rests on a number that does not describe the system."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence:
      - ref: E2
    resolution_test: "A statement of what the harness executes, or production latency data for comparison."
    inapplicability_condition: "Would apply if the harness stubbed the data layer, used synthetic query plans, or otherwise diverged from the production request path."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "The objection is a reasonable prior about benchmarks in general, and E2 addresses the specific mechanism directly: the harness runs the production service against a cluster using production query plans with no stubbed layer. A general practice being common is not evidence that it obtained here, and the supplied documentation is evidence that it did not."

  - id: O2
    objection: "A 40% reduction in p99 latency is implausibly large and is more likely a measurement error than a real gain."
    why_it_might_matter: "An implausible estimate suggests a broken instrument, which would invalidate the benchmark."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "The raw per-run measurements with percentile distributions, or an independent replication on a second environment."
    inapplicability_condition: "Would not apply if the improvement were reproducible across independent runs on a second environment."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "The objection rests entirely on a general impression about how large latency improvements usually are, which is background knowledge and no observation in the boundary. It is not excluded, and E1 reports a consistent direction across five runs, but nothing supplied measures run-to-run variance against the effect size. Magnitude-based incredulity is not evidence of a broken instrument."

overall_result:
  result: retain
  statement: "No supported problem identified from the available evidence. Two plausible objections were raised and neither is carried by the supplied material: harness fidelity is addressed by the harness documentation, and the implausible-magnitude concern rests on general expectation rather than any observation. The audited claim is the measured benchmark result, so production latency remains outside this boundary and is listed as a limitation rather than treated as a defect."
  objections_supporting_result: []
  basis:
    - "E2 contradicts the harness-fidelity objection"
    - "E3 documents that no other code change was deployed in the window"
    - "O2 has no supporting evidence in the boundary"

evaluator_error:
  ground_truth_available: false
  ground_truth_source: null
  evaluator_error_rate: evaluator_error_rate_not_determinable

independence:
  passes_performed:
    - "claim formalization"
    - "candidate generation"
    - "evidence testing"
    - "self anti-red-team"
  independent_judgments: false
  disclosure: "All passes ran in one model in one conversation and are correlated. No pass was counted as evidence. Whether the objections here were genuinely unfounded is not established by this audit, since no ground truth about production latency was available."

limitations:
  - "No external research was performed or authorized."
  - "Production latency was never measured, so this audit says nothing about whether the production system improved."
  - "The benchmark environment's relationship to production is documented in one file, which was not independently verified."
  - "A retain result here means this audit found nothing warranting revision. It is not evidence that the migration improved production latency."
```

## Why it is not a pass by default

The two rejected objections both have empty `supporting_evidence`. An evaluator
that filled those lists from background knowledge would produce a record that
passes a glance and fails an audit. That is the specific thing a reviewer should
check in this test, and it is why `supporting_evidence` is a required field rather
than a convenience.