# Test: unsupported objection

**Purpose.** A plausible objection with no evidence behind it. The protocol must
not promote it into a demonstrated problem.

**The failure this catches.** Escalation without a warrant — the objection is
generated, sounds reasonable, and arrives at the reader as a finding because it
was written in the same register as one. The symptom is `supported` or
`substantive_problem` with an empty `supporting_evidence`.

**What this test does not establish.** That the objection is unfounded. It
establishes only that the supplied evidence does not support it. The objection may
be entirely correct and simply untested here, which is a different situation from
being wrong.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The onboarding redesign increased activation by 12%."

**Supplied.** `experiment-design.md`, `results.md`.

**Not supplied.** Any post-hoc segment analysis or switching analysis.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `decision_impact` |
| --- | --- | --- | --- | --- |
| O1 activation is confounded by user type | `unsupported` | `possible` | `meaningful_risk` | `no_effect` |
| O2 more steps increase cognitive load | `unsupported` | `possible` | `meaningful_risk` | `no_effect` |
| O3 no confidence interval published | `supported` | `supported` | `minor_limitation` | `no_effect` |

Overall: **`retain`**. One objection is supported and it is immaterial — a real
finding that does not become a defect.

## Pass criteria

1. O1 and O2 have `status: unsupported` and empty `supporting_evidence`.
2. Neither reaches `evidence_status: demonstrated` or
   `problem_status: substantive_problem`.
3. Overall result is not `revise`.
4. O3 is `supported` with a non-empty `supporting_evidence` — the audit is not
   simply returning nulls.
5. The overall statement does not claim the 12% figure is settled.

## Record

```yaml
claim:
  original: "The onboarding redesign increased activation by 12%."
  subject: onboarding redesign
  predicate: increased activation by 12%
  scope: the tested onboarding flow for new signups
  population: new signups during the test window
  timeframe: 14 days from signup
  baseline: the control flow, as assigned
  intended_interpretation: a causal effect of the redesign
  dependent_decision: whether to keep the redesigned onboarding
  missing_definitions:
    - "activation is not defined in the supplied documents"
  load_bearing_assumptions:
    - "arm assignment was randomised and independent of user type"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether the supplied experiment supports the 12% causal claim"
  out_of_scope:
    - "onboarding usability beyond the activation measure"
    - "long-run retention"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "experiment-design.md section 2"
      content: "Arms were assigned by randomisation at signup with a 50/50 split and balanced strata on acquisition channel."
    - ref: E2
      type: document
      locator: "experiment-design.md section 3"
      content: "Activation is defined as completing one substantive action within 14 days of signup; the metric was fixed before the test began."
    - ref: E3
      type: document
      locator: "results.md section 1"
      content: "Activation was 12.1% on the redesigned flow and 10.8% on the control flow across 22,400 randomised signups."
    - ref: E4
      type: document
      locator: "results.md section 3"
      content: "Results are reported as a point estimate. No confidence interval or standard error is published."
  unavailable_evidence:
    - "a segment analysis by user type or acquisition channel beyond the randomisation strata"
    - "a switching or discontinuity analysis"
    - "confidence intervals on the activation difference"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O1, the selection concern"
      - "O2, the cognitive-load concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "Users who activate are disproportionately the users who would have activated anyway, so the redesign did not cause the increase."
    why_it_might_matter: "If the increase reflects selection rather than the redesign, keeping the flow would deliver nothing that would not have happened regardless."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E1
    resolution_test: "A segment or switching analysis showing whether the activation gap persists within matched strata on prior engagement."
    inapplicability_condition: "Would not apply if activation differences vanished within matched strata, or if the measured increase were fully explained by selection on unobserved user type."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "The selection hypothesis is the standard threat to any randomised comparison and E1 shows randomised assignment with balanced strata, which is the design feature that addresses it. Nothing supplied refutes selection on unmeasured attributes, and the segment analysis that would settle it was not provided, so the hypothesis is neither established nor excluded. Reporting it as a problem would rest an inference on the general expectation that selection exists rather than on anything in the boundary."

  - id: O2
    objection: "The redesign lengthened the flow, so it may have increased cognitive load and depressed activation for slower users."
    why_it_might_matter: "A net-positive average could hide harm to a subgroup."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "Activation measured separately for users above and below the median completion time on the redesigned flow."
    inapplicability_condition: "Would not apply if activation were equal or higher across completion-time subgroups."
    status: unsupported
    evidence_status: possible
    problem_status: meaningful_risk
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "The premise that the flow lengthened is not documented in the boundary, and no supplied observation is broken out by completion time, so neither the mechanism nor a subgroup effect is indicated. It is recorded rather than dropped because it names a concrete test, and it is not counted as a problem with the claim under audit."

  - id: O3
    objection: "The 12% figure is published as a point estimate with no interval, so its precision cannot be judged from the report."
    why_it_might_matter: "A point estimate without an interval invites over-reading a small effect as decisive."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E4
    contradicting_evidence: []
    resolution_test: "A confidence interval on the activation difference computed from the reported group counts."
    inapplicability_condition: "Would not apply if results.md published confidence intervals or standard errors."
    status: supported
    evidence_status: supported
    problem_status: minor_limitation
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "E4 confirms the interval is absent, so the objection is supported by a documentation fact. It is a limitation in reporting rather than a demonstrated problem with the result: E1 establishes randomisation and E3 reports group counts, so the interval is computable from what was supplied and the gap is one of presentation. Publishing the interval would fix it without changing the claim."

overall_result:
  result: retain
  statement: "No supported problem identified from the available evidence. Two causal objections to the 12% figure are plausible and untested, one of them the standard selection threat to a randomised design; neither is carried by anything supplied, and the segment analysis that would settle the more important of them was not provided. One documentation limitation is supported and immaterial: no interval accompanies the point estimate, and the counts needed to compute one are supplied. The untested objections remain open and are recorded with the specific analyses that would resolve them."
  objections_supporting_result: []
  basis:
    - "E1 shows randomised assignment with balanced strata, and no supplied evidence refutes selection on unmeasured attributes"
    - "E2 fixes the activation metric before the test"
    - "E4 supports the missing-interval limitation, classified immaterial"
    - "no objection has supporting evidence that would establish a demonstrated problem"

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
  disclosure: "All passes ran in one model in one conversation and are correlated. Nothing here was adjudicated externally. The null result is not a true negative: the selection objection might well turn out to be correct if the missing segment analysis were supplied, and nothing in this record should be read as clearing it."

limitations:
  - "No external research was performed or authorized."
  - "The two unsupported objections are untested, not refuted. O1 in particular is the standard threat to this design and would be settled by a segment analysis that was not supplied."
  - "activation is undefined in the supplied documents, so the denominator and the substantive-action threshold could not be checked."
  - "A retain result records that this audit found nothing warranting revision. It is not evidence that the 12% figure is established, and it expires when the missing segment analysis is supplied."
```

## The distinction this file protects

`unsupported` and `false` are different verdicts, and collapsing them is how an
audit turns its ignorance into a finding.

O1 might be right. The protocol does not know that, and does not claim to. It
records that the evidence to establish it was not supplied, names the analysis
that would supply it, and stops. "We do not know" is the honest report;
"there is no selection effect" would be a second claim, with no evidence behind it
either — dressed as a finding because it is negative rather than positive.