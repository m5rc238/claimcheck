# Example: a null result that cannot be read as validation

**What this exercises.** `retain`. The result most red-team systems cannot produce,
and the one most easily overstated in the write-up.

The test this file is designed to pass is not "did the audit find the right
things." It is: **can a reader mistake this for a verdict on the claim?**

> All data and figures in this file are synthetic and illustrative.

## Input

**Claim.** "The checkout redesign reduced payment failures for returning customers
by 12%."

**Supplied.** `experiment-log.md` (design, duration, weekly failure counts),
`change-log.md` (what changed and when), `failure-taxonomy.md` (failure
categories, including fraud-check rejections).

**Not supplied.** Post-redesign data for new customers; any change made after the
redesign window.

**Not authorized.** External research.

## Record

```yaml
claim:
  original: "The checkout redesign reduced payment failures for returning customers by 12%."
  subject: checkout redesign
  predicate: reduced payment failure rate for returning customers by 12%
  scope: returning customers, the redesign window
  population: returning customers who initiated checkout during the experiment
  timeframe: eight weeks, 2026-05-04 to 2026-06-29
  baseline: pre-redesign failure rate for the same customer segment
  intended_interpretation: a causal attribution to the redesign
  dependent_decision: whether to keep the redesign live for all customers
  missing_definitions:
    - "returning customer is not defined in the supplied documents"
  load_bearing_assumptions:
    - "failure classification did not change between the two periods"
  formalization_status: sufficient

scope:
  in_scope:
    - "attribution of the observed reduction to the redesign"
    - "whether the comparison is stable across the measured window"
  out_of_scope:
    - "effects on new customers"
    - "long-term payment behaviour"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "experiment-log.md section 2"
      content: "Weekly returning-customer failure rate fell from 4.1% to 3.6% across eight weeks, a 12.2% relative reduction, on 18,400 and 18,900 checkout initiations respectively."
    - ref: E2
      type: document
      locator: "change-log.md section 1"
      content: "The redesign changed layout, field ordering, and autofill only. Fraud-check configuration, retry logic, and gateway routing were unchanged across the experiment window."
    - ref: E3
      type: document
      locator: "failure-taxonomy.md section 2"
      content: "Fraud-check rejections are recorded as a distinct category in both periods; validation, timeout, and gateway categories are separately coded in both."
    - ref: E4
      type: document
      locator: "experiment-log.md appendix A"
      content: "Seasonal history for the same segment shows prior comparable windows ranging from 3.7% to 4.3%, with the redesign window result at the low end of that range and the pre-window rate inside it."
    - ref: E5
      type: document
      locator: "experiment-log.md section 4"
      content: "Raw weekly counts are reported. No significance test or confidence interval is computed."
  unavailable_evidence:
    - "payment failure data for new customers after the redesign"
    - "any change made after 2026-06-29 that might affect later rates"
    - "a pre-registered analysis plan for this experiment"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O5, the attribution concern"
      - "O6, the seasonality concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The failure-rate change is attributable to something other than the redesign, since the redesign could not have affected gateway or fraud-check failures."
    why_it_might_matter: "If the reduction came from an unrelated cause, keeping the redesign is not supported by this experiment."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E2
      - ref: E3
    resolution_test: "The change log and failure taxonomy, checked for any non-redesign change and for movement in categories the redesign could not influence."
    inapplicability_condition: "Would apply if the change log showed a concurrent change to payment processing, or if the reduction were concentrated in categories the redesign could not touch."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "E2 records that payment-processing configuration was untouched, and E3 records consistent category coding in both periods, so the redesign was capable of affecting exactly the categories that moved. This objection asserts an unattributable alternative cause and the supplied record addresses it directly, so it is refuted rather than merely untested."

  - id: O2
    objection: "The reduction is ordinary seasonal movement and would have occurred without the redesign."
    why_it_might_matter: "Seasonality would mean the redesign is not doing the work the experiment credits it with."
    basis: mixed
    supporting_evidence:
      - ref: E4
    contradicting_evidence:
      - ref: E4
    resolution_test: "Seasonal history for the same segment and calendar window, compared against both the pre-window and redesign-window rates."
    inapplicability_condition: "Would apply if the same seasonal pattern had historically produced a 12% relative reduction in this window."
    resolution_note: "E4 supports the objection only to the extent that it shows normal week-to-week variation; the same record shows the observed drop sits at the edge of the historical range rather than within it. The objection is therefore raised on evidence and refuted by the same evidence, which is reported rather than concealed."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "Seasonality is a serious alternative explanation and E4 is cited on both sides deliberately: it documents historical variation of 3.7 to 4.3 percent, the pre-window rate of 4.1 sits inside it, and the redesign window at 3.6 sits at its edge. A drop to the edge of the historical range is not the shape ordinary seasonal movement produces, so on this evidence the objection does not survive."

  - id: O3
    objection: "No significance test was computed, so the 12% reduction may be indistinguishable from noise."
    why_it_might_matter: "Without an interval around the estimate, the size of the effect cannot be weighed against sampling variation."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E5
    contradicting_evidence: []
    resolution_test: "A confidence interval on the difference in failure rates between the two windows, computed from the reported weekly counts."
    inapplicability_condition: "Would not apply if the experiment log reported confidence intervals or a pre-registered analysis plan."
    status: supported
    evidence_status: supported
    problem_status: minor_limitation
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "E5 confirms the log reports raw counts without an interval or test, so the objection is supported by a real documentation gap. It is a limitation of the reporting rather than a demonstrated problem with the result: the underlying counts are supplied and on 37,000 initiations a 0.5 point difference is not delicate. It does not warrant changing the claim or the decision, and the fix is to publish the interval rather than to revise the conclusion."

  - id: O4
    objection: "The redesign harmed new customers, who were not measured."
    why_it_might_matter: "A redesign kept live for all customers could degrade the segment it was not tested on."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E1
    resolution_test: "New-customer failure rates before and after the redesign window."
    inapplicability_condition: "Would apply if new-customer rates were supplied and had worsened across the redesign window."
    status: not_applicable
    evidence_status: unknown
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "The claim is scoped to returning customers, and E1 reports returning-customer rates only, so this objection falls outside the audited claim rather than conflicting with it. The absence of new-customer data is a real gap in the rollout decision and is recorded in limitations, but it is not a defect in this claim and not grounds for classifying the objection as supported."

  - id: O5
    objection: "Autofill improvements may have merely moved failures to a later, unmeasured step rather than removing them."
    why_it_might_matter: "A redesign that relocates friction rather than eliminating it would not reduce customer cost."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Post-experiment data on downstream checkout abandonment and support contacts for the redesigned flow."
    inapplicability_condition: "Would not apply if downstream abandonment and support-contact rates were supplied and flat or lower after the redesign."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "Friction relocation is a recognised pattern in checkout changes, but the supplied experiment log measures nothing downstream of the payment step, so no observation in the boundary bears on it either way. It is a plausible concern outside this claim's scope, recorded so it is not lost, and it is not counted as a problem with the claim under audit."

  - id: O6
    objection: "Eight weeks is too short to observe a durable effect."
    why_it_might_matter: "A transient improvement would decay shortly after the change was announced to customers."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Failure rates for the redesigned flow in the four weeks following the experiment window."
    inapplicability_condition: "Would not apply if post-window data showed the reduced rate persisting."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "Durability cannot be assessed inside an eight-week window by definition, and the supplied documents contain no post-window data. This is a scope boundary rather than a defect in the claim, which is explicitly scoped to the redesign window. It is recorded as unsupported because nothing indicates the effect was transient, and as a limitation because it bears on the rollout decision rather than on the audited claim."

overall_result:
  result: retain
  statement: "No supported problem identified from the available evidence. Two of the six candidate objections were raised on evidence and then refuted by the same evidence, one reports a documentation limitation that does not bear on the claim, and three rest on background knowledge or fall outside the claim's scope. This result is about the evidence supplied for the eight-week returning-customer window. It is not a statement that the redesign works, and it does not cover new customers, durability after the window, or downstream friction."
  objections_supporting_result: []
  basis:
    - "E2 and E3 refute the unattributable-cause objection"
    - "E4 raises and refutes the seasonality objection on the same record"
    - "E5 supports a reporting limitation classified immaterial to the claim"
    - "E1 scopes the audited claim to returning customers, excluding O4"
    - "O5 and O6 rest on background knowledge with no supporting observation in the boundary"

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
  disclosure: "Every pass ran in one model in one conversation and shares that model's priors. No pass was counted as evidence for or against any objection, and the refutations rest on cited documents rather than on the model's judgment. The absence of objections O5 and O6 is not a finding that those concerns are unfounded: it reflects that the evidence boundary contains nothing which bears on them."

limitations:
  - "No external research was performed or authorized."
  - "The audited claim covers returning customers in an eight-week window. New-customer effects, post-window durability, and downstream friction are outside it and untested."
  - "returning customer is undefined in the supplied documents, so the segment boundaries cannot be checked."
  - "No significance test was supplied, so the 12% figure carries no interval. The underlying counts are available and a reader can compute one."
  - "A retain result means this audit found nothing warranting revision. It is not evidence that the claim holds, and it expires the moment the evidence boundary changes."
```

## What to notice

**The statement is a controlled sentence.** It opens with the mandated phrasing, it
names what was actually done, and it ends by naming what was not covered. There is
no word in it that upgrades the claim. `schema.md` rule R12 checks the first half
mechanically; the closing clause exists because the mechanical check cannot catch
an understatement that understates in the other direction.

**Six candidate objections were generated, and none survived as supported.** That
is the point of the test. A system that found a supported problem here would have
found one by inflating a risk or by reading a scope boundary as a defect. The
pressure to produce a finding is exactly what makes that outcome likely.

**O2 is raised on evidence and refuted by that same evidence.** E4 is cited in
both lists, deliberately, and the `resolution_note` says so in plain words. This
is harder to do than either ignoring the objection or accepting it, and it is the
case most likely to be quietly dropped — a supported objection can be disposed of
by relabelling it as unsupported, which is a smaller mistake than overclaiming
and still a mistake.

**O3 is `supported` and still changes nothing.** A real gap in reporting, no
demonstrated problem with the claim, immaterial, no effect on the decision. This
is the status combination that distinguishes auditing from attacking: the
protocol can report a finding and decline to inflate it.

**O4 is `not_applicable`, not `unsupported`.** The claim does not cover new
customers, so an objection about new customers is outside its scope rather than
unproven. The gap is real and is recorded in `limitations`, where it belongs —
carried into `scope.out_of_scope` rather than laundered into a finding.

**O5 and O6 stay on the record at low confidence.** Real concerns, outside the
evidence boundary, marked `unsupported` rather than deleted. Deleting them would
lose information a reader may act on; promoting them would invent findings about a
claim they do not bear on.

**`retention` on the overall result is about this audit, not the claim.** The
limitation says it outright: a `retain` result expires when the evidence boundary
changes. A reader who takes `retain` as "verified" has misread the record — which
is why the record says so before they have to infer it.