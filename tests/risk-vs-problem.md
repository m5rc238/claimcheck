# Test: risk versus demonstrated problem

**Purpose.** A legitimate methodological risk for which no evidence shows the risk
actually affected the result. The protocol must record it as a risk and stop
there.

**The failure this catches.** The inferential slide, and it is the single most
common error in red-teaming:

> The assignment method is questionable → *therefore the design is flawed* →
> *therefore the result is invalid*.

Each arrow is available, none is supported. A design weakness and a corrupted
result are different claims, and only one of them is evidenced.

**What this test does not establish.** That the risk is harmless. A risk with no
evidence of materialisation is not the same as a risk that is absent, and the
resolution test recorded here is the thing that would tell the two apart.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The field experiment showed the reminder SMS increased clinic
attendance by 6%."

**Supplied.** `trial-protocol.md`, `attendance-data.md`, `assignment-notes.md`.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `decision_impact` |
| --- | --- | --- | --- | --- |
| O1 alternating-week assignment may be confounded | `supported` | `supported` | `meaningful_risk` | `investigate` |
| O2 three clinics cannot generalise | `unsupported` | `possible` | `meaningful_risk` | `no_effect` |

Overall: **`investigate`**.

The assertion under test: O1 is a real, evidenced design concern whose
`problem_status` is `meaningful_risk` and whose `evidence_status` is **not**
`demonstrated`. No objection reaches `substantive_problem`. Nothing reaches
`revise`.

## Pass criteria

1. O1 has `problem_status: meaningful_risk`. Not `substantive_problem`.
2. O1 has `evidence_status` of `supported`, not `demonstrated`.
3. O1 has `decision_impact: investigate`, not `revise`.
4. No objection anywhere in the record has `problem_status: substantive_problem`.
5. The statement does not say the result is invalid, unsound, or unusable.
6. The resolution test is concrete and would distinguish the risk from its
   rejection.

## Record

```yaml
claim:
  original: "The field experiment showed the reminder SMS increased clinic attendance by 6%."
  subject: reminder SMS intervention
  predicate: increased clinic attendance by 6%
  scope: the three clinics in the trial, over the trial window
  population: patients with scheduled follow-up appointments at the three clinics
  timeframe: 2026-05-01 to 2026-06-30
  baseline: the alternating weeks in which no SMS was sent, at the same clinics
  intended_interpretation: a causal effect of sending the reminder SMS
  dependent_decision: whether to fund the SMS programme beyond the three trial clinics
  missing_definitions:
    - "attendance is not defined beyond the protocol's own coding rule"
  load_bearing_assumptions:
    - "clinic weeks alternate cleanly with respect to staffing and demand"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the trial design supports the causal claim"
  out_of_scope:
    - "patients who do not have scheduled follow-up appointments"
    - "cost per appointment"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "trial-protocol.md section 2"
      content: "The pre-specified analysis was an intention-to-treat comparison of SMS weeks against non-SMS weeks within clinic, run as specified."
    - ref: E2
      type: dataset
      locator: "attendance-data.md summary rows"
      content: "Attendance was 71.2% in SMS weeks and 67.1% in non-SMS weeks across 1,840 scheduled appointments."
    - ref: E3
      type: document
      locator: "assignment-notes.md section 1"
      content: "Weeks were assigned in alternating blocks by clinic, starting 2026-05-05 at clinic A, 2026-05-12 at clinic B, and 2026-05-19 at clinic C. No randomisation was used."
    - ref: E4
      type: document
      locator: "assignment-notes.md section 3"
      content: "Clinic A's first SMS week coincided with a two-day closure of its phlebotomy service for equipment maintenance."
    - ref: E5
      type: document
      locator: "trial-protocol.md section 4"
      content: "The three clinics were selected as the network's highest-volume sites with comparable demographic catchment areas."
  unavailable_evidence:
    - "weekly attendance broken out per clinic, so the clinic A anomaly can be isolated"
    - "staffing and demand data by week"
    - "any randomisation or matched-pair assignment record"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O2, the generalisability concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "Assigning weeks in alternating blocks rather than randomly leaves the comparison open to confounding by anything that follows a two-week cycle, such as staffing levels or seasonal demand."
    why_it_might_matter: "If demand moved with the calendar rather than with the SMS, the 6% attendance difference would be attributable to timing rather than to the intervention."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E3
      - ref: E4
    contradicting_evidence:
      - ref: E1
    resolution_test: "Weekly attendance split by clinic across all twelve weeks, with clinic A's closure weeks excluded, comparing SMS against non-SMS weeks within each clinic."
    inapplicability_condition: "Would not apply if weekly attendance moved with the alternating blocks independently of SMS status, or if assignment had been randomised with a stated procedure."
    status: supported
    evidence_status: supported
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: medium
    rationale: "E3 establishes the non-randomised alternating assignment as a documented property of the design and E4 shows a concrete calendar event landing inside a treatment block, which is the mechanism this objection describes. That makes it more than a generic methodological worry: it is supported by evidence about this trial. E1 is cited in the other column because the pre-specified analysis and the intention-to-treat comparison are real design strengths, but they do not answer a confounding question. The evidence supports that the risk is genuine, and nothing in the boundary shows it operated on the result, so the concern stays a risk rather than becoming a defect in the 6% figure."

  - id: O2
    objection: "Three clinics cannot support a general claim, so the result should not be funded beyond them."
    why_it_might_matter: "A programme extended on evidence from three sites could underperform elsewhere."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E5
    resolution_test: "Attendance and response rates at clinics outside the trial, or a stated argument about why these three are representative."
    inapplicability_condition: "Would apply if the trial sites had been unrepresentative by documented selection, or if outside sites were shown to differ materially."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "The objection asserts unrepresentativeness without evidence of it, and E5 documents the selection basis: highest-volume sites with comparable catchment areas, which is a reasonable basis for transfer rather than a refutation of it. Small samples limit generalisation, but the trial protocol itself states no inference beyond the three clinics, so this addresses a question the claim did not pose."

overall_result:
  result: investigate
  statement: "The 6% difference is measured as stated and the pre-specified analysis was run, but the design assigns weeks in alternating blocks without randomisation, and a dated maintenance closure inside one clinic's first treatment week is the kind of calendar event that confound would produce. That is an evidenced concern about the comparison, and no supplied data shows whether it moved the result: the weekly figures are not broken out by clinic, so the closure weeks cannot be isolated. The difference between a risk and a defect here turns on one computation, splitting weekly attendance by clinic and excluding the closure weeks. Until that is done, the 6% figure is neither established nor impeached, and the concern is recorded as a risk rather than as a defect in the trial."
  objections_supporting_result:
    - O1
  basis:
    - "E3 documents non-randomised alternating-block assignment"
    - "E4 shows a dated calendar event inside a treatment block"
    - "E1 records that the pre-specified analysis was run as specified"
    - "no supplied data isolates whether the confounding affected the measured difference"

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
  disclosure: "All passes ran in one model in one conversation and are correlated. In this case the correlated-error risk is specifically the inference from design weakness to invalid result, which a second pass by the same model is likely to reproduce rather than check. No external adjudicator and no ground truth participated, and the model did not resolve the ambiguity by arguing harder about it."

limitations:
  - "No external research was performed or authorized."
  - "attendance is defined only by the protocol's own coding rule, which was not independently checked."
  - "The audit establishes that the design cannot rule out calendar confounding. It does not establish that confounding occurred, and it offers no estimate of how much of the 6% difference is attributable to the SMS."
  - "O1 being supported means the risk is real, not that the result is wrong. The two are different claims and only one has evidence here."
```

## The sentence to protect

The overall statement says the 6% figure is "neither established nor impeached."
That is the whole test in one clause.

A weaker audit writes *"the trial design is flawed, so the 6% result is unreliable."*
The design concern is real and documented; the conclusion does not follow from it.
Nothing in the boundary shows how much of the difference the SMS caused, and a
protocol that says "unreliable" has quietly promoted a risk into a defect — the
exact move this file exists to fail.