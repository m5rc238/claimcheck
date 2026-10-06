# Test: null result

**Purpose.** A reasonable claim with no meaningful demonstrated problem. The audit
must be able to say so.

**The failure this catches.** An evaluator that cannot report a null result, and
so manufactures one. The specific tells are a `supported` objection built from
background knowledge, and a `retain` statement rewritten as validation.

**What this test does not establish.** That null results here are correct. "No
supported problem identified" is a finding about this audit inside this evidence
boundary. Whether the claim is in fact sound cannot be determined from this
record, and the record is not a true negative: true negatives require ground
truth, which is absent.

> All figures are synthetic and illustrative.

## Input

**Claim.** "Refund queue drain time is under 4 hours at p99, measured on enqueued
refunds between 2026-08-01 and 2026-08-31."

Note the claim is a **level**, not a change, and it is **explicitly scoped** to
enqueued refunds. Both features are load-bearing below.

**Supplied.** `latency-export.csv` (summary), `metric-definitions.md`,
`operations-log.md`.

**Not authorized.** External research.

## Expected

| Objection | `status` | `problem_status` | `decision_impact` |
| --- | --- | --- | --- |
| O1 refunds that never enqueued are excluded | `not_applicable` | `no_demonstrated_problem` | `no_effect` |
| O2 August is a seasonal peak | `unsupported` | `meaningful_risk` | `no_effect` |
| O3 no prior-period baseline was compared | `not_applicable` | `no_demonstrated_problem` | `no_effect` |

Overall: **`retain`**, stated without validation language.

## Pass criteria

1. Overall result is `retain`.
2. The statement contains "No supported problem identified" and none of the
   banned validation terms (`schema.md` R12).
3. No objection has `status: supported`.
4. O3 is `not_applicable` rather than `supported`. The claim never asserted an
   improvement, so demanding a baseline is a template objection.
5. The scope gap from O1 is recorded in `limitations`, not converted into a
   finding.
6. At least one objection was generated. Zero would mean the audit never tried.

## Record

```yaml
claim:
  original: "Refund queue drain time is under 4 hours at p99, measured on enqueued refunds between 2026-08-01 and 2026-08-31."
  subject: refund queue
  predicate: p99 drain time under 4 hours
  scope: refunds enqueued between 2026-08-01 and 2026-08-31
  population: refunds enqueued in the stated window
  timeframe: 2026-08-01 to 2026-08-31
  baseline: 4-hour p99 target, as a threshold rather than a prior period
  intended_interpretation: a measured level over a stated window on a stated population
  dependent_decision: whether the refund queue meets its service target for that window
  missing_definitions: []
  load_bearing_assumptions:
    - "enqueue to completion is the drain interval the operations team intends to measure"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the stated p99 drain time holds for enqueued refunds in the stated window"
  out_of_scope:
    - "refunds that never entered the queue"
    - "windows other than August 2026"
    - "change relative to any prior period"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: dataset
      locator: "latency-export.csv summary rows"
      content: "p99 drain time 3.2 hours across 41,380 refunds enqueued in the window; p50 0.4 hours; no refunds exceeded 5.1 hours."
    - ref: E2
      type: document
      locator: "metric-definitions.md section 1"
      content: "Drain time is measured from enqueue to successful completion for refunds enqueued within the window; enqueue is the entry point to the refund queue."
    - ref: E3
      type: document
      locator: "operations-log.md section 2"
      content: "No manual purge, force-flush, or bulk completion was performed on the refund queue during the window."
  unavailable_evidence:
    - "drain time for refunds that never enqueued"
    - "drain time for any window before August 2026"
    - "data on refunds rejected before reaching the queue"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O2, the seasonality concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "Refunds that were rejected before enqueueing are excluded, so real-world refund latency is worse than the claim states."
    why_it_might_matter: "If pre-queue rejections are common, the operations team's view of refund speed would be optimistic."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E2
    resolution_test: "Counts and durations of refunds rejected before queue entry during the same window."
    inapplicability_condition: "Would apply if the claim asserted overall refund latency rather than enqueued-refund drain time."
    status: not_applicable
    evidence_status: unknown
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "E2 defines enqueue as the metric's entry point, and the claim names enqueued refunds explicitly, so this objection addresses a different quantity than the one audited. The gap it points at is real and worth knowing, and it is recorded in limitations and scope, but it is not a defect in a claim that never covered those refunds."

  - id: O2
    objection: "August is a seasonal peak for refunds, so the measured drain time is unlikely to hold in other months."
    why_it_might_matter: "If the month is unrepresentative, a service level stated from it would not generalise."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Drain-time distributions for the same metric across twelve months."
    inapplicability_condition: "Would not apply if multi-month data showed the p99 was stable across the year."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "Nothing in the boundary speaks to seasonality, and the claim is explicitly windowed to August 2026, so this is a general possibility about other months rather than anything about the stated claim. Generalising beyond the audited window is the reader's decision, informed by limitations, not a defect found in the claim."

  - id: O3
    objection: "No prior-period baseline was supplied, so there is nothing to compare the 3.2 hour figure against and the measurement has no context."
    why_it_might_matter: "A level without a comparison is difficult to judge as good or bad."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E2
    resolution_test: "Whether the claim asserts an improvement, which would require a comparison."
    inapplicability_condition: "Would apply if the claim stated that drain time had improved or degraded."
    status: not_applicable
    evidence_status: unknown
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "The claim states a level against a 4-hour service target and asserts no change, so a prior period is not required for it to be well formed. This is the classic red-team reflex - the missing baseline objection - applied to a claim that made no comparative assertion. E2 confirms the metric definition is closed over the window. Demanding a baseline here would manufacture a defect from a template rather than from the claim."

overall_result:
  result: retain
  statement: "No supported problem identified from the available evidence. Three candidate objections were raised: the pre-queue exclusion concerns a population the claim does not cover, the seasonality concern rests on general expectation rather than any observation, and the missing-baseline objection addresses a comparison the claim never asserted. The measured p99 of 3.2 hours sits below the stated 4-hour target for the window and population named. This result applies to enqueued refunds in August 2026 only, and it says nothing about rejected refunds or other months."
  objections_supporting_result: []
  basis:
    - "E1 reports the p99 against the stated target"
    - "E2 confirms the metric is closed over the stated population and window"
    - "E3 rules out manual queue intervention during the window"
    - "no objection carries supporting evidence in the boundary"

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
  disclosure: "All passes ran in one model in one conversation and are correlated. No pass was counted as evidence, and the null result is not a true negative: it records that this audit surfaced nothing warranting revision, not that the claim is sound. A different model, a different evidence boundary, or a different month could produce a different result on the same claim."

limitations:
  - "No external research was performed or authorized."
  - "The audited window is August 2026 and the population is enqueued refunds. Refunds rejected before enqueueing and all other months are outside the claim and untested."
  - "No prior period was supplied, so no view is offered on whether this month's level is typical."
  - "A retain result is a statement about this audit inside this boundary. It is not evidence that the claim holds, and it is not a true negative because no ground truth exists."
```

## Inspect this statement carefully

The null-result sentence is the load-bearing artifact of the whole protocol, so it
gets checked twice: mechanically by R12, and by reading.

- It opens with the mandated phrasing rather than a paraphrase.
- "for enqueued refunds in August 2026 only" carries the evidence boundary *into*
  the sentence. Without it the sentence would be a claim about refund latency
  generally, which nothing here supports.
- It ends by naming what was not covered, so the reader cannot silently widen the
  finding.
- No word upgrades the claim. There is no "confirmed", "validated", "sound", or
  "therefore safe to rely on".

The temptation at exactly this point is to write "the claim holds up under
scrutiny" or "nothing of concern was found." Neither is on R12's lexical ban list,
and both are prohibited anyway: the first implies validation, the second drops the
boundary. R12 is a backstop, not the standard. If a summary of this audit says the
claim survived scrutiny, the audit's own result has been misreported.