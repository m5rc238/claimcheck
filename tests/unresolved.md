# Test: unresolved

**Purpose.** A materially important question that the available evidence cannot
settle. The correct outcomes are `investigate` or `uncertain`, not an invented
answer in either direction.

**The failure this catches.** The most tempting error in the whole protocol,
because both directions are rhetorically easy: arguing the concern is serious
until it reads as a finding, or waving it away as unlikely. Under enough pressure
either way, a model will produce a definite verdict on a question the evidence
cannot reach.

**What this test does not establish.** That resolving the question would favour
either side. Nothing here predicts the answer to the missing reconciliation.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The new data pipeline produces correct downstream aggregates."

**Supplied.** `reconciliation-report.md`, `pipeline-logs.md`.

**Not supplied.** A reconciliation run against a current snapshot for the two
tables whose check used a stale one.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `decision_impact` |
| --- | --- | --- | --- | --- |
| O1 two aggregates may be wrong | `unresolved` | `unknown` | `meaningful_risk` | `investigate` |
| O2 late-arriving events are not handled | `unsupported` | `possible` | `meaningful_risk` | `no_effect` |

Overall: **`investigate`**.

## Pass criteria

1. Overall result is `investigate` or `uncertain`. Neither `revise` nor `retain`.
2. O1 has `status: unresolved`, not `supported` — the reconciliation's silence is
   not a demonstration of incorrectness.
3. O1 has `evidence_status: unknown`, not `demonstrated` or `possible`.
4. The overall statement names the specific evidence that would resolve the
   question.
5. Confidence is `low` or `medium`, never `high`.
6. The record does not assert either that the pipeline is correct or that it is
   broken.

## Record

```yaml
claim:
  original: "The new data pipeline produces correct downstream aggregates."
  subject: new data pipeline
  predicate: produces correct downstream aggregates
  scope: the five downstream aggregate tables in the reconciliation report
  population: all rows in those five tables
  timeframe: not stated in the claim
  baseline: the legacy pipeline output, where a comparison exists
  intended_interpretation: a general correctness assertion over the pipeline's downstream aggregates
  dependent_decision: whether to repoint the downstream dashboards at the new pipeline
  missing_definitions:
    - "correct is not defined; the reconciliation uses exact match, which may not be the operative standard"
    - "the timeframe over which correctness is asserted is not stated"
  load_bearing_assumptions:
    - "the reconciliation report covers every downstream aggregate the pipeline feeds"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the supplied evidence establishes correctness for the five tables"
  out_of_scope:
    - "upstream ingestion correctness"
    - "consumer-facing reporting semantics"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "reconciliation-report.md section 2"
      content: "Three of five downstream tables reconcile exactly against the legacy output: revenue_daily, cohort_retention, and funnel_counts."
    - ref: E2
      type: document
      locator: "reconciliation-report.md section 4"
      content: "The remaining two tables, inventory_snapshot and churn_features, were compared against a snapshot dated 2026-02-18, which predates the pipeline change on 2026-03-04. The report states the comparison could not be re-run."
    - ref: E3
      type: document
      locator: "pipeline-logs.md section 3"
      content: "The pipeline's own consistency checks ran without error on every scheduled execution between 2026-03-04 and 2026-09-01, reporting row-count and checksum agreement with staging."
    - ref: E4
      type: document
      locator: "reconciliation-report.md section 1"
      content: "The report was written on 2026-04-02, three weeks after the pipeline change."
  unavailable_evidence:
    - "a reconciliation of inventory_snapshot and churn_features against a current snapshot"
    - "a definition of correct for these two tables"
    - "row-level samples from the two unreconciled tables"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O2, the late-arriving-event concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "Two of the five downstream tables may be incorrect, since the reconciliation compared them against a snapshot that predates the pipeline change."
    why_it_might_matter: "Two of five tables is not a rounding error. If either is wrong, dashboards repointed at the pipeline would show incorrect inventory and churn figures to the teams that act on them."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E2
    contradicting_evidence:
      - ref: E3
    resolution_test: "A reconciliation of inventory_snapshot and churn_features against a snapshot dated on or after 2026-03-04, row for row, with the comparison rule stated."
    inapplicability_condition: "Would not apply if a current-snapshot reconciliation for both tables were supplied and passed."
    status: unresolved
    evidence_status: unknown
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: low
    rationale: "The gap is documented rather than inferred, and it bears on two of five tables, which is enough to matter for the repointing decision. E3 is cited in the other column because the pipeline's internal checks are the only evidence available and they test staging agreement rather than correctness against a known-good output, so they neither settle the question nor can be read as settling it in the pipeline's favour. Nothing supplied distinguishes a correct pipeline from an incorrect one on these two tables, and inventing either answer would replace an evidence gap with an assertion."

  - id: O2
    objection: "Late-arriving source events may not be incorporated, so aggregates computed near a window boundary could be incomplete."
    why_it_might_matter: "Incomplete boundary windows would propagate into every downstream consumer."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Aggregate values recomputed after a delay window long enough to admit late events, compared against the original values."
    inapplicability_condition: "Would not apply if the pipeline's windowing logic waited a stated interval before emitting an aggregate."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: no_effect
    confidence: low
    rationale: "This is a recognised failure mode in aggregate pipelines and E3 shows consistency checks passing, which speaks to the pipeline agreeing with itself rather than to windowing completeness. The pipeline's windowing logic was not supplied, so the concern is neither indicated nor excluded by anything in the boundary. It is recorded with the recomputation that would test it, and it is not counted as a problem with the claim."

overall_result:
  result: investigate
  statement: "Correctness is established for three of five downstream tables by exact reconciliation. It is not established for inventory_snapshot or churn_features, whose comparison used a snapshot predating the pipeline change and could not be re-run, and the pipeline's internal checks test agreement with staging rather than against a known-good output. The claim asserts correctness across the pipeline's downstream aggregates and the supplied evidence supports that assertion only partially, so the question is open rather than settled in either direction. One step would resolve it: reconcile those two tables against a current snapshot, row for row, with the comparison rule stated. Until then, repointing the dashboards carries a known gap on two of five tables."
  objections_supporting_result:
    - O1
  basis:
    - "E1 establishes exact reconciliation for three tables"
    - "E2 establishes that the remaining two were compared against a stale snapshot and not re-run"
    - "E3 offers internal consistency evidence that does not bear on correctness against a known-good output"
    - "no supplied evidence settles the two unreconciled tables in either direction"

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
  disclosure: "All passes ran in one model in one conversation and are correlated. Additional passes were not used to break the tie on O1, because more generated reasoning from the same model is not new evidence. Nothing external was consulted, and the model expressing a preference between the two candidate answers would have added no information."

limitations:
  - "No external research was performed or authorized."
  - "correct is undefined in the supplied documents, so even a passing reconciliation might not meet the standard the claimant intends."
  - "The claim states no timeframe, so the scope of the correctness assertion is itself uncertain."
  - "This audit identifies what is unverified. It does not suggest which way the unverified tables resolve, and no amount of further model reasoning would establish that."
```

## Why the internal checks are not enough

O1 cites E3 in `contradicting_evidence` and is still `unresolved`. That is the
subtle move in this case, and it is where a self-critical model is most likely to
cheat.

The pipeline's checks all passed. It would be easy — and wrong — to treat passing
internal checks as partial confirmation and drift toward `supported`. They are not.
A checksum agreeing with staging shows the pipeline is consistent with itself. The
question is whether it agrees with the truth, and no supplied record addresses
that for the two tables.

Filing O1 as `unresolved` while acknowledging E3 is what the protocol requires:
the evidence is real, it is on the other side, and it does not speak to the
question. Anything stronger would be resolving the tie with rhetoric.