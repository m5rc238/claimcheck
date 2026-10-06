# Test: false negative

**Purpose.** A claim containing a genuine, demonstrable substantive problem. The
protocol must locate it and return `revise`.

**The failure this catches.** The mirror image of false positives: an audit so
reluctant to assert anything that it misses a defect sitting in the supplied
evidence. Anti-inflation discipline can overshoot into a protocol that returns
`retain` on everything, which is equally uninformative.

**What this test does not establish.** That the protocol detects real problems
reliably. Detection on one hand-built case is not a recall estimate, and there is
no ground truth about how many defects exist in claims generally. One test passing
is not a general reliability claim. See
`evaluator_error_rate_not_determinable` below.

> All figures are synthetic and illustrative.

## Input

**Claim.** "Our A/B test showed the new checkout button increases revenue per
visitor by 8%."

**Supplied.** `experiment-log.md` (arm assignment, duration, stopping rule),
`results.md`.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `materiality` | `decision_impact` |
| --- | --- | --- | --- | --- | --- |
| O1 optional stopping inflates the estimate | `supported` | `demonstrated` | `substantive_problem` | `material` | `revise` |
| O2 arm assignment confounded by time of day | `supported` | `demonstrated` | `substantive_problem` | `material` | `revise` |
| O3 the new button colour is inaccessible | `not_applicable` | `unknown` | `no_demonstrated_problem` | `immaterial` | `no_effect` |

Overall: **`revise`**.

## Pass criteria

1. At least one objection carries the full chain: `supported` +
   `demonstrated` + `substantive_problem` + `material`.
2. Overall result is `revise`, not `investigate`.
3. Each revising objection has non-empty `supporting_evidence` with resolvable
   locators.
4. The overall statement describes what should change, not merely what is wrong.
5. The unsupported-by-evidence objection (O3) is not promoted to `supported`.

## Record

```yaml
claim:
  original: "Our A/B test showed the new checkout button increases revenue per visitor by 8%."
  subject: new checkout button
  predicate: increases revenue per visitor by 8%
  scope: the tested storefront and traffic window
  population: storefront visitors during the test window
  timeframe: the two days the test ran
  baseline: the control button, as assigned
  intended_interpretation: a causal attribution to the button change
  dependent_decision: whether to ship the button to all storefronts
  missing_definitions:
    - "revenue per visitor is not defined in the supplied documents"
  load_bearing_assumptions:
    - "arm assignment was independent of visitor attributes"
  formalization_status: sufficient

scope:
  in_scope:
    - "the validity of the experiment as a basis for the 8% claim"
  out_of_scope:
    - "button visual design"
    - "long-run revenue effects"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: document
      locator: "experiment-log.md section 1"
      content: "Variant assignment was by time of day: variant shown 06:00-18:00, control 18:00-06:00, from 2026-06-12."
    - ref: E2
      type: document
      locator: "experiment-log.md section 3"
      content: "The test was stopped on 2026-06-14, two days after start, at the stated rule 'stop when the variant reaches p below 0.05'."
    - ref: E3
      type: document
      locator: "results.md section 1"
      content: "Revenue per visitor was 8.4% higher on the variant across the two days."
    - ref: E4
      type: document
      locator: "experiment-log.md section 4"
      content: "Variant share by daypart for the control period differs from the variant period; evening share runs 61-67% of daily traffic."
  unavailable_evidence:
    - "a pre-registered stopping rule or fixed horizon"
    - "any randomisation record"
    - "revenue per visitor by daypart"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "O3, the accessibility concern"
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The test was stopped as soon as significance appeared, so the 8% estimate is inflated by optional stopping and does not measure a durable effect."
    why_it_might_matter: "Shipping the button on an estimate biased upward by stopping rule means the expected gain is smaller than stated, and the measurement procedure would repeat the inflation on every future button test."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E2
      - ref: E3
    contradicting_evidence: []
    resolution_test: "The pre-registered stopping rule or a fixed test horizon stated before the test began, or the effect measured over a pre-specified duration after the last change."
    inapplicability_condition: "Would not apply if the two-day duration had been fixed in advance and the significance rule were a reporting convention rather than a stopping criterion."
    status: supported
    evidence_status: demonstrated
    problem_status: substantive_problem
    materiality: material
    decision_impact: revise
    confidence: high
    rationale: "E2 shows the test ended at the moment significance was reached rather than at a pre-specified horizon, and E3 reports the estimate from that truncated run. A procedure demonstrated in the log to stop on significance produces an estimate biased upward, so the 8.4% figure does not support an 8% causal claim. If this objection were resolved against the claim, the shipping decision would stand on a different measurement; because it is not resolvable against the claim, the claim and the stated effect size must change."

  - id: O2
    objection: "Arm assignment by time of day confounds the arms with traffic composition, so the difference between them is not attributable to the button."
    why_it_might_matter: "Evening traffic may convert differently regardless of button design, which would produce a gap between arms with no behavioural cause."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E1
      - ref: E4
    contradicting_evidence: []
    resolution_test: "Revenue per visitor computed within matched dayparts for both arms, or a randomised assignment record."
    inapplicability_condition: "Would not apply if arms were assigned by randomisation independent of the time of visit."
    status: supported
    evidence_status: demonstrated
    problem_status: substantive_problem
    materiality: material
    decision_impact: revise
    confidence: high
    rationale: "E1 documents assignment by daypart and E4 documents that daypart composition is uneven, so the two arms did not see comparable traffic and no randomisation record exists in the boundary. The design confound is demonstrated by the assignment rule itself rather than inferred from a correlation, which is what separates this from a supported risk. Resolving it against the claim would restore the shipping case; nothing supplied does, so the attribution must be restated or the test repeated."

  - id: O3
    objection: "The new button colour fails a contrast requirement and excludes low-vision users."
    why_it_might_matter: "An inaccessible control is a defect regardless of conversion effects."
    basis: background_knowledge
    supporting_evidence: []
    contradicting_evidence: []
    resolution_test: "The button colour values and a contrast ratio computed against the WCAG threshold."
    inapplicability_condition: "Would not apply if colour values were supplied and met the contrast threshold."
    status: not_applicable
    evidence_status: unknown
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: low
    rationale: "The audited claim concerns a measured revenue effect and supplies no colour values, so the claim as stated makes no assertion about accessibility and this objection cannot bear on it. The concern may be entirely valid and belongs in an accessibility review, which is outside this claim's scope rather than refuted by it."

overall_result:
  result: revise
  statement: "The 8% figure is not carried by the experiment as run. The test stopped at the moment the result crossed significance, and arms were assigned by time of day rather than randomised, so both the estimate and its attribution to the button are compromised by documented features of the design rather than by inference. The claim should change to state the measurement as exploratory, and the shipping decision should rest either on a fixed-horizon test with randomised assignment or on an effect estimate recomputed within matched dayparts. Separately, button contrast has not been assessed and sits outside this claim."
  objections_supporting_result:
    - O1
    - O2
  basis:
    - "E2 establishes the optional-stopping rule in the test log"
    - "E1 and E4 establish daypart-based assignment with uneven traffic composition"
    - "both objections satisfy the revise threshold of supported, demonstrated, substantive, and material"

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
  disclosure: "All passes ran in one model in one conversation and share its priors. No pass was counted as evidence; both findings rest on the experiment log. No external adjudicator participated, so whether these are the two most important defects in this experiment is a judgment that has not been independently checked."

limitations:
  - "No external research was performed or authorized."
  - "The audit establishes that the documented design cannot support the claim. It does not establish the true size of the button's effect, which would require a corrected test."
  - "revenue per visitor is undefined in the supplied documents, so the denominator could not be checked."
  - "Passing this case demonstrates that one designed defect was found. It is not evidence of recall, and it does not show that other planted or real defects would also be found."
```

## The point of including this test

A protocol tuned only against false positives will return `retain` on everything,
which is a different way of being uninformative. This case exists so the test
suite fails an implementation that has learned to withhold judgment — the
symptom to watch for is `retain` appearing whenever a documented design flaw is
visible in the supplied evidence.