# Example: a research claim where the risk is not promoted to a defect

**What this exercises.** The most common false positive in red-teaming: a
legitimate methodological concern inflating into a claimed defect. The concern
here is real. The defect is not.

> All data, documents, and figures in this file are synthetic and illustrative.
> They are not from a real study.

## Input

**Claim.** "Rolling out the guided claims flow will cut first-contact resolution
time by 20% across all lines of business."

**Supplied.** `pilot-readout.md` (results and duration), `sampling-plan.md`
(sample frame and case-selection rules).

**Not supplied.** Resolution-time data for lines other than the two pilot lines;
any pilot data after April 2026.

**Not authorized.** External research.

## Record

```yaml
claim:
  original: "Rolling out the guided claims flow will cut first-contact resolution time by 20% across all lines of business."
  subject: guided claims flow rollout
  predicate: reduces first-contact resolution time by 20%
  scope: all lines of business
  population: claims adjuster population
  timeframe: next two quarters
  baseline: current manual triage workflow
  intended_interpretation: a general causal claim about the rollout
  dependent_decision: whether to fund and expand the rollout
  missing_definitions:
    - "first-contact resolution time is not defined in the supplied documents"
  load_bearing_assumptions:
    - "adjuster experience with the new flow is comparable across lines of business"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the measured reduction transfers beyond the pilot lines"
  out_of_scope:
    - "cost of the rollout"
    - "long-run adjuster learning effects"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "pilot-readout.md section 3, table 2"
      content: "Pilot reduced median first-contact resolution time 21% across the two pilot lines."
    - ref: E2
      type: document
      locator: "sampling-plan.md section 1"
      content: "The pilot drew cases from commercial auto lines only; the proposed rollout targets all lines of business."
    - ref: E3
      type: document
      locator: "sampling-plan.md section 4"
      content: "All eligible cases in the two pilot lines were logged; no case was excluded, and case selection is documented."
    - ref: E4
      type: document
      locator: "pilot-readout.md section 5"
      content: "The pilot ran eight weeks, March to April 2026, covering 412 cases."
  unavailable_evidence:
    - "resolution-time data for any line of business other than commercial auto"
    - "pilot data after April 2026"
    - "definiton of first-contact resolution time used by the measurement team"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O1, the transferability concern"
      - "O3, the measurement-effect concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The pilot sampled only two lines of business, so the measured 21% reduction may not transfer to the lines the rollout targets."
    why_it_might_matter: "The rollout's expected saving is computed across all lines, so a line-specific effect size would change the funding decision."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E2
    contradicting_evidence: []
    resolution_test: "Resolution-time measurements from at least one non-commercial line operating the guided flow, or a documented argument that line composition does not affect the metric."
    inapplicability_condition: "Would not apply if the pilot sampling frame had covered every line the rollout targets."
    status: supported
    evidence_status: supported
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: medium
    rationale: "E2 directly documents that the pilot frame and the rollout target differ, so transfer is an open question rather than a settled one. Nothing supplied shows the effect was absent outside the pilot lines, so this is a risk with evidence behind it, not a demonstrated defect in the pilot."

  - id: O2
    objection: "The pilot sample is invalid, so the 21% reduction cannot support any claim about the rollout."
    why_it_might_matter: "If the sample were invalid the pilot result would carry no weight, and the rollout case would rest on nothing."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E3
      - ref: E4
    resolution_test: "Documentation of case exclusions, non-response, or coverage gaps in the pilot sample."
    inapplicability_condition: "Would apply only if case selection were undocumented, incomplete, or subject to exclusion rules."
    status: contradicted
    evidence_status: supported
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "The objection asserts sample invalidity, and E3 documents complete, unfiltered logging of all eligible cases with a stated selection rule. E4 shows a defined eight-week window and a case count. No supplied evidence indicates exclusion or coverage failure, so this objection is refuted by the record rather than merely left unproven."

  - id: O3
    objection: "Adjuster behaviour changed during the pilot because teams knew the flow was being measured, inflating the measured reduction."
    why_it_might_matter: "A measurement effect of this kind would mean the pilot overstates what the rollout will deliver."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "A blinded or staggered rollout comparison that conceals which period is the treatment period."
    inapplicability_condition: "Would not apply if adjuster behaviour were independently shown to be unchanged across the pilot window."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: low
    rationale: "Measurement reactivity is a recognised methodological concern, but it is supplied here only as background knowledge and no document, observation, or measurement in the boundary speaks to it. It is not excluded, and it is not indicated. Reporting it as a problem would convert a general possibility into a finding about this pilot."

overall_result:
  result: investigate
  statement: "The measured reduction is supported for the two lines actually tested, and the sample-quality objection is refuted by the sampling documentation. Generalization to the remaining lines is not established by anything supplied, so the rollout's expected saving is unresolved. Two items would settle it: transferability data from a non-pilot line, and a design that conceals the treatment period."
  objections_supporting_result:
    - O1
    - O3
  basis:
    - "E2 documents a gap between the pilot frame and the rollout target"
    - "E3 and E4 contradict the sample-invalidity objection"
    - "no supplied evidence speaks to measurement reactivity"

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
  disclosure: "All four passes ran in one model in a single conversation. They are correlated, not independent, and no pass was treated as evidence for or against any objection. No external adjudicator and no ground truth participated in this audit."

limitations:
  - "No external research was performed or authorized; every finding rests on two supplied documents."
  - "first-contact resolution time is undefined in the supplied documents, so the 20% target and the 21% measurement may not be measured the same way."
  - "O3 rests entirely on background knowledge and cannot be resolved without a new design, so it is reported as an open question rather than a finding."
  - "No ground truth exists for whether the effect would transfer; the audit cannot tell you whether this audit was right."
```

## What to notice

**O1 and O2 are the same worry at different evidentiary strengths.** Both concern
whether the pilot supports the rollout. O1 is a *transferability gap* the evidence
actually documents, so it survives as a risk that warrants investigation. O2 makes
a stronger claim — that the sample is invalid — and the sampling documentation
refutes it. Note that O2 is `contradicted`, not merely `unsupported`: there is
evidence pointing the other way, which is a different and stronger finding than
"we did not find support."

**O3 is deliberately left standing as an open question.** Measurement reactivity
is a real concern in rollout pilots. Nothing in the boundary speaks to it. It is
recorded as `unsupported` with `possible` evidence status — it was not deleted,
and it was not promoted to a finding. Deleting it would lose information;
promoting it would fabricate one.

**The overall result is `investigate`, not `revise`.** Nobody demonstrated a
substantive problem with the pilot. What is missing is data, and the protocol
distinguishes missing data from a detected defect — that difference is what
`investigate` exists to express.

**`retain` was not available here.** A material, unresolved question existed.
Reporting `retain` would have been an overstatement, and the empty-slot design
punishes that by forcing the question into `investigate`.