# Example: auditing an AI-generated critique

**What this exercises.** The recursive case. The input is not a claim — it is a
*critique* produced by an LLM, and the audit must treat every assertion inside it
as a claim requiring the same discipline.

This is the case the repository exists for, because model-generated critiques are
widely treated as authoritative findings when nothing has checked them.

> All data and figures in this file are synthetic and illustrative.

## Input

**Claim under critique.** "Users who complete onboarding within 24 hours retain
at 3× the rate of slower completers."

**The prior critique being audited.** An LLM was asked to "red-team this
onboarding finding." It produced three objections:

1. "The study used a 2019 dataset, so the conclusions are out of date."
2. "The study did not account for seasonality in retention."
3. "The effect size is not robust to the choice of baseline, so the 3× figure is
   fragile."

**Supplied.** `cohort-analysis.md`, `dataset-provenance.md`.

**Not supplied.** A robustness appendix or any alternative-baseline analysis.

## Record

```yaml
claim:
  original: "Users who complete onboarding within 24 hours retain at 3x the rate of users who take longer."
  subject: onboarding completion timing and retention
  predicate: is associated with a 3x retention difference
  scope: the analyzed signup cohort
  population: signups in the analyzed cohort
  timeframe: 90 days post-signup
  baseline: users completing onboarding after 24 hours
  intended_interpretation: descriptive association; the critique read it as causal
  dependent_decision: whether a prior AI critique should be accepted as a set of findings
  missing_definitions:
    - "retain is not explicitly defined in the supplied analysis"
  load_bearing_assumptions:
    - "the supplied provenance document describes the data actually analyzed"
  formalization_status: sufficient

scope:
  in_scope:
    - "whether each assertion in the prior critique is carried by the supplied evidence"
  out_of_scope:
    - "the product decision itself"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "dataset-provenance.md section 1"
      content: "The analyzed cohort was collected between 2026-01-04 and 2026-06-30. No 2019 data appears in the analysis."
    - ref: E2
      type: document
      locator: "cohort-analysis.md section 4"
      content: "Retention is reported by signup month across all six months, so month-of-year effects are visible in the supplied tables."
    - ref: E3
      type: dataset
      locator: "cohort-analysis.md appendix B"
      content: "Retention is measured as any logged activity on day 90."
    - ref: E4
      type: document
      locator: "cohort-analysis.md section 6"
      content: "The analysis states a single baseline group, users completing onboarding after 24 hours, and does not report alternative baselines."
  unavailable_evidence:
    - "a robustness appendix or alternative-baseline analysis"
    - "the audit log of the prior critique run, including its prompt and any sources it consulted"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O3, the critique-of-the-critique hypothesis"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The prior critique's assertion that the study used a 2019 dataset is correct, so its other objections deserve similar weight."
    why_it_might_matter: "If one critique point lands, a reader may treat the remaining points as equally grounded."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E1
    resolution_test: "The dataset provenance record, showing the collection window of the analyzed cohort."
    inapplicability_condition: "Would apply if the provenance record showed pre-2026 data."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "The critique named a specific defect and the supplied provenance record places the cohort in early 2026. The assertion is refuted by a document, so it is contradicted rather than merely unsupported. Its being the critique's most concrete-sounding objection is not evidence that it was checked; the check is E1."

  - id: O2
    objection: "The prior critique's suggestion that seasonality was ignored is unsupported, because the analysis reports retention by signup month."
    why_it_might_matter: "A critique that lists unaddressed methodological steps inflates the apparent fragility of a finding."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E2
    resolution_test: "The cohort analysis tables, checked for a per-month breakdown."
    inapplicability_condition: "Would apply if the analysis reported only a pooled rate with no monthly breakdown."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: medium
    rationale: "E2 shows retention reported across all six signup months, which is the structural precondition for a seasonality check. The critique asserted the step was missing without citing the analysis. That the check may still be inadequate is a separate question this objection does not raise."

  - id: O3
    objection: "The prior critique's baseline-fragility point remains open, because no alternative-baseline analysis was supplied and cannot be ruled out from the analysis as written."
    why_it_might_matter: "If the 3x figure moves substantially under a different comparison group, the number itself is unstable and should not be quoted."
    basis: mixed
    supporting_evidence:
      - ref: E4
    contradicting_evidence: []
    resolution_test: "Recomputing the retention ratio using a 48-hour or 72-hour comparison group from the underlying cohort data."
    inapplicability_condition: "Would not apply if the cohort data were supplied and the ratio proved stable across reasonable alternative baselines."
    status: unresolved
    evidence_status: unknown
    problem_status: meaningful_risk
    materiality: potentially_material
    decision_impact: investigate
    confidence: low
    rationale: "E4 documents a single stated baseline and no robustness analysis, so the critique's point is not refuted by anything supplied. But absence of a robustness appendix is not evidence that the ratio is fragile, and the underlying data needed to settle it was not provided. The point is material to how the figure should be quoted, so it is recorded as unresolved rather than dismissed or adopted."

  - id: O4
    objection: "The prior critique was wrong to treat the finding as causal, because the claim as written is descriptive."
    why_it_might_matter: "This would remove the critique's most substantive objection, leaving the descriptive claim intact."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "A statement from the analysis authors of the intended reading of the finding."
    inapplicability_condition: "Would not apply if the surrounding decision record shows the finding was relied on causally."
    status: unsupported
    evidence_status: possible
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "This counter-argument to the critique comes from reading the claim's wording, which is a matter of interpretation rather than an observation. The decision record that would show how the finding was actually relied on was not supplied, so the point is neither established nor refuted, and it is not the audit's place to infer intent from phrasing."

overall_result:
  result: investigate
  statement: "Two of the three objections in the prior critique are refuted by the supplied documents, including the one that sounded most concrete. The third, baseline fragility, is genuinely open: no robustness analysis was supplied and the data needed to run one was not provided, so it is neither adopted nor dismissed. The critique should not be treated as a set of findings, and it should not be discarded either. One specific computation would settle the remaining question."
  objections_supporting_result:
    - O3
  basis:
    - "E1 refutes the outdated-data assertion"
    - "E2 refutes the seasonality assertion"
    - "E4 leaves baseline fragility unresolved and no supplied evidence settles it"
    - "the prior critique's audit log was not available, so its reasoning could not be examined directly"

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
  disclosure: "This audit ran in one model, and the critique under audit was also produced by a language model, very possibly the same one. Any agreement between them is correlated, not corroborative, and shared training data means the audit is liable to reproduce the critique's blind spots rather than correcting them. No human adjudicator and no external ground truth participated. The two refutations rest on supplied documents, which is the strongest kind of evidence available here, and not on the model's judgment."

limitations:
  - "The prior critique's prompt, sources, and audit log were not supplied, so its reasoning could not be examined. A refuted assertion is refuted; whether it was careless or mistaken cannot be told from this."
  - "No external research was performed or authorized."
  - "Whether the ratio is stable under an alternative baseline remains open, and no amount of further model reasoning would close it; the cohort data are needed."
  - "Refuting three of the critique's assertions does not establish that the fourth is the only remaining problem, and it says nothing about critiques of this shape in general."
```

## What to notice

**The audit's first job was to check the critique, not the claim.** O1 and O2
audit statements the critique made. They were refuted by documents, not by better
reasoning — which is the whole point. A model arguing against a model is still a
model.

**Correlated origin is disclosed, not hidden.** If the critique and the audit came
from the same model, they share blind spots. The disclosure says so plainly rather
than presenting the refutations as an independent check.

**A refuted objection is not a discarded one.** O1 and O2 record *why* the
critique's points fail, with locators. A reader who disagrees can check the same
documents. The record survives audit; "the model disagreed" would not.

**O3 is the interesting one.** The critique's point was not refuted — the
robustness analysis simply does not exist. The correct outcome is neither
"critique wins" nor "critique loses." It is `investigate`, with the specific
computation that would settle it named. This is the case a template-driven
red-team handles worst, because the winning move is to compute something, and
losers are scored on rhetorics alone.

**O4 shows restraint in the other direction.** An unsupported counter-argument to
the critique was raised and then declined, because inferring intent from phrasing
is not what this protocol licenses.

**The most useful output is the disclosure.** Two refutations and one open
question. A system that had produced three confident-sounding critiques of its own
here would have looked more thorough and been less useful.