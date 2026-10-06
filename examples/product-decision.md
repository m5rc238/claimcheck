# Example: a product decision where a problem *is* demonstrated

**What this exercises.** The path to `revise`. An objection that is `supported`,
`demonstrated`, `material`, and therefore must change the claim. Contrast with
[`research-claim.md`](research-claim.md), where the same protocol produced no
demonstrated problem at all.

> All data and figures in this file are synthetic and illustrative.

## Input

**Claim.** "Users who complete onboarding within 24 hours retain at 3× the rate of
users who take longer, so we should add a 24-hour onboarding deadline."

**Supplied.** `cohort-analysis.md` (cohort definitions and retention numbers),
`pre-onboarding-activity.md` (engagement metrics recorded before onboarding
began), `analysis-plan.md` (stated design).

**Not supplied.** Any randomized onboarding design.

**Not authorized.** External research.

## Record

```yaml
claim:
  original: "Users who complete onboarding within 24 hours retain at 3x the rate of users who take longer, so we should add a 24-hour onboarding deadline."
  subject: onboarding completion deadline
  predicate: causes higher retention and should be adopted
  scope: new signups in the product
  population: new signup cohort, 2026 Q1 and Q2
  timeframe: 90 days post-signup
  baseline: users completing onboarding after 24 hours
  intended_interpretation: a causal claim justifying a product change
  dependent_decision: whether to ship a 24-hour onboarding deadline
  missing_definitions:
    - "retain is not defined; the supplied analysis implies a 90-day active-user measure but does not state it"
  load_bearing_assumptions:
    - "the two cohorts differ only in onboarding speed"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the comparison supports a causal reading"
    - "whether a deadline is the appropriate intervention"
  out_of_scope:
    - "onboarding UX quality"
    - "pricing"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "cohort-analysis.md section 1"
      content: "4120 users completing onboarding within 24 hours retained at 31.4% over 90 days; 9130 users taking longer retained at 10.5%."
    - ref: E2
      type: document
      locator: "analysis-plan.md section 2"
      content: "The analysis is observational. Cohorts are defined by observed onboarding completion time; no assignment of onboarding timing occurred."
    - ref: E3
      type: document
      locator: "pre-onboarding-activity.md section 2"
      content: "Users completing onboarding within 24 hours had a median 5.1 pre-onboarding sessions, versus 1.4 for slower completers."
    - ref: E4
      type: dataset
      locator: "cohort-analysis.md appendix B"
      content: "Retention is measured as any logged activity on day 90."
  unavailable_evidence:
    - "a randomized comparison of onboarding timing"
    - "retention conditioned on matched pre-onboarding activity"
    - "the onboarding completion rate under a deadline"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "the selection-mechanism hypothesis behind O1"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The claim reads an observational comparison as a causal effect; users who finish fast were already more engaged before onboarding began."
    why_it_might_matter: "If pre-existing engagement drives both fast completion and retention, a deadline would not change retention for the users it targets, and the shipped feature would cost conversion without delivering the retention gain."
    basis: mixed
    supporting_evidence:
      - ref: E2
      - ref: E3
    contradicting_evidence: []
    resolution_test: "Retention compared between the two cohorts at matched levels of pre-onboarding session count, or a randomized onboarding-timing design."
    inapplicability_condition: "Would not apply if onboarding timing were assigned experimentally, or if the two cohorts matched on pre-onboarding engagement."
    status: supported
    evidence_status: demonstrated
    problem_status: substantive_problem
    materiality: material
    decision_impact: revise
    confidence: high
    rationale: "E2 states the design is observational, so nothing assigned timing. E3 shows the fast cohort was already three times more active before onboarding, and E1 shows the retention gap. Together they demonstrate that a pre-existing difference plausibly accounts for the gap, so the causal reading in the claim is not carried by its evidence. The recommendation would change if this objection were resolved against the claim: the deadline would no longer be justified by this analysis."

  - id: O2
    objection: "No baseline cohort was used in the retention comparison, so the 3x figure has nothing to be measured against."
    why_it_might_matter: "A ratio without an absolute reference can be misread as a large effect size."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E1
      - ref: E4
    resolution_test: "Inspection of cohort-analysis.md for a stated reference group."
    inapplicability_condition: "Would apply only if the retention comparison were reported without any named reference group or measure."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "The comparison does name both arms and the measure: E1 gives the two cohort retention rates and E4 defines retention as day-90 activity. The 3x figure is a ratio of two stated rates, not a ratio against a missing baseline. The reporting concern does not survive contact with the supplied analysis."

  - id: O3
    objection: "Day-90 activity may reflect a billing or trial artefact rather than durable product value."
    why_it_might_matter: "If day-90 activity tracks billing cycles rather than habit, the retention metric itself is the wrong target."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Retention measured at day 180 as well as day 90, with billing-cycle dates recorded per cohort."
    inapplicability_condition: "Would not apply if day-90 activity were shown to predict later activity independent of billing cycles."
    status: unresolved
    evidence_status: unknown
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: low
    rationale: "Metric validity is material to this decision, and the supplied documents define retention as day-90 activity without discussing durability. Nothing available either supports or rules out the artefact, so the question cannot be settled inside the evidence boundary and is reported as unresolved rather than argued in either direction."

overall_result:
  result: revise
  statement: "The retention gap is real as an observation, but the analysis does not support the causal reading the claim rests on: the fast cohort was substantially more active before onboarding began, and no assignment of onboarding timing occurred. The claim and the recommendation should change to an association that has not been tested for a causal effect. Separately, whether day-90 activity measures durable value is unresolved and would need a longer horizon to settle."
  objections_supporting_result:
    - O1
  basis:
    - "E2 establishes the observational design"
    - "E3 establishes a large pre-onboarding difference between the cohorts"
    - "O1 meets the revise threshold of supported, demonstrated, substantive, and material"

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
  disclosure: "Every pass ran in one model in one conversation and shares that model's priors and blind spots. No pass was counted as evidence for or against an objection, and no second model was consulted. Whether the selection mechanism really explains the gap is not settled by this audit."

limitations:
  - "No external research was authorized, so no independent replication of the cohort analysis was consulted."
  - "retain is undefined in the supplied analysis; E4 was used as the best available reading of the measure."
  - "The confounding in O1 is demonstrated as present, not as the sole cause of the retention gap; the size of its contribution is not estimable from the supplied data."
  - "This audit cannot determine whether the recommended revision is correct, only what the supplied evidence does and does not support."
```

## What to notice

**`revise` had to be earned.** O1 satisfied all four conditions — `supported`,
`demonstrated`, `substantive_problem`, `material` — and the rationale states the
counterfactual: the recommendation would change if the objection were resolved
against the claim. Remove any one of those and the protocol forces
`investigate` instead. A single "supported objection" would not have been enough.

**Demonstrated means demonstrated, not proved.** E2 and E3 show that a
confounder is *present and large*. They do not establish that it fully explains
the gap, and the rationale says so. The result is `revise` on the causal
*reading*, not on a quantified decomposition of the effect.

**O2 is `contradicted`, not `unsupported`.** The documents were checked and named
a reference group, so this is evidence pointing the other way — a stronger
finding than silence. The distinction matters for anyone auditing the audit: a
refuted objection and an untested one leave different traces.

**O3 stays unresolved rather than being argued.** Metric-validity doubt is
plausible and material, and nothing in the boundary settles it. The protocol
declines to resolve it in either direction, which is the honest outcome — and the
one a rhetorically capable model is most likely to skip.

**The audit revised the claim, not the world.** What changed here is the wording
of a recommendation, because the evidence did not support the wording as written.