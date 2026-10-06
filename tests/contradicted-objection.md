# Test: contradicted objection

**Purpose.** Evidence directly conflicts with a candidate objection. The correct
status is `contradicted`.

**The failure this catches.** Filing a refuted objection as merely `unsupported`,
which understates what was established. It matters downstream: `unsupported` means
"nobody looked," `contradicted` means "somebody looked and the evidence points the
other way." A reader weighing whether to trust a critique cannot treat those
alike. The second failure is the opposite one — upgrading a plausible objection to
`supported` because it survived a token check.

**What this test does not establish.** That the refutation is correct. It rests on
the supplied documents; nothing external verified them.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The 2026 pricing change increased enterprise upgrades by 18%."

**Supplied.** `upgrade-history.csv`, `pricing-change-note.md`,
`market-notes.md`.

**Not authorized.** External research.

## Expected

| Objection | `status` | `evidence_status` | `problem_status` | `materiality` | `decision_impact` |
| --- | --- | --- | --- | --- | --- |
| O1 a competitor outage caused the increase | `contradicted` | `demonstrated` | `no_demonstrated_problem` | `immaterial` | `no_effect` |
| O2 the change cut revenue per account | `supported` | `demonstrated` | `substantive_problem` | `material` | `revise` |

Overall: **`revise`**. A refuted objection and a supported problem coexist; the
protocol does not let a contradiction anywhere in the audit become a null result.

## Pass criteria

1. O1 has `status: contradicted`, not `unsupported`, and not `not_applicable` —
   the evidence bears on it rather than falling outside the claim's scope.
2. O1 carries non-empty `contradicting_evidence` with resolvable locators.
3. O1 has `problem_status: no_demonstrated_problem`.
4. O2 is `supported` with non-empty `supporting_evidence`.
5. Overall result is `revise`, not `retain` — refuting O1 does not license
   ignoring O2.

## Record

```yaml
claim:
  original: "The 2026 pricing change increased enterprise upgrades by 18%."
  subject: 2026 pricing change
  predicate: increased enterprise upgrades by 18%
  scope: enterprise accounts on the self-serve and sales-assisted tiers
  population: enterprise accounts active between 2024-09 and 2026-08
  timeframe: 2026-03 to 2026-08, following the 2026-03-01 change
  baseline: enterprise upgrade rate in the eight months preceding the change
  intended_interpretation: a causal attribution to the pricing change
  dependent_decision: whether to hold the new pricing or revert it
  missing_definitions:
    - "enterprise account is not defined in the supplied documents"
  load_bearing_assumptions:
    - "upgrade volume otherwise reflects underlying demand"
  formalization_status: sufficient

scope:
  in_scope:
    - "attribution of the upgrade increase to the pricing change"
    - "commercial consequences of the change"
  out_of_scope:
    - "acquisition pricing"
    - "non-enterprise segments"
  evidence_cutoff: "2026-09-30"

evidence_boundary:
  available_evidence:
    - ref: E1
      type: dataset
      locator: "upgrade-history.csv monthly rows"
      content: "Monthly enterprise upgrades rose from 41 to 62 between 2025-07 and 2026-02, then to 73 in 2026-03."
    - ref: E2
      type: document
      locator: "pricing-change-note.md section 1"
      content: "The pricing change took effect 2026-03-01. Monthly upgrades grew in every one of the eight months before it, from 33 to 41."
    - ref: E3
      type: document
      locator: "market-notes.md section 2"
      content: "A competitor outage on 2026-02-11 affected that competitor's status page; no outage affected our service in 2026-03 or later."
    - ref: E4
      type: document
      locator: "pricing-change-note.md section 3"
      content: "Enterprise revenue per account fell 3.1% between the quarter before the change and the quarter after."
  unavailable_evidence:
    - "a control group or holdout of enterprise accounts on the old pricing"
    - "an estimate separating price effects from expansion within existing accounts"
    - "an elasticity model"
  background_knowledge:
    role: hypothesis_generation_only
    used_for: []
  external_research: unavailable

candidate_objections:
  - id: O1
    objection: "The 18% increase was caused by a competitor outage rather than by the pricing change."
    why_it_might_matter: "If an outage drove the increase, holding the new pricing carries the commercial cost without the benefit."
    basis: supplied_evidence
    supporting_evidence: []
    contradicting_evidence:
      - ref: E1
      - ref: E2
      - ref: E3
    resolution_test: "The competitor incident timeline against the monthly upgrade series."
    inapplicability_condition: "Would apply if the increase began in the outage month or if upgrades grew in line with an outage-driven pattern."
    status: contradicted
    evidence_status: demonstrated
    problem_status: no_demonstrated_problem
    materiality: immaterial
    decision_impact: no_effect
    confidence: high
    rationale: "The objection locates the increase in a specific alternative cause, and three records address it: the outage is dated 2026-02-11, before the 2026-03-01 change; upgrades were already growing from 33 to 41 across the preceding eight months; and the jump to 73 lands in the change month. The timing and shape both fail to fit the outage, so this objection is contradicted by evidence rather than merely left without support, and the reader can check the same three records."

  - id: O2
    objection: "The pricing change reduced revenue per enterprise account by 3.1%, so holding it trades a small upgrade gain for a revenue loss."
    why_it_might_matter: "A net revenue decline would change the hold-or-revert decision regardless of how many accounts upgraded."
    basis: supplied_evidence
    supporting_evidence:
      - ref: E4
    contradicting_evidence: []
    resolution_test: "Revenue per account by month for twelve months, and the split between new, expansion, and renewal revenue."
    inapplicability_condition: "Would not apply if revenue per account held or rose after the change, or if the decline were accounted for by mix rather than price."
    status: supported
    evidence_status: demonstrated
    problem_status: substantive_problem
    materiality: material
    decision_impact: revise
    confidence: medium
    rationale: "E4 records the 3.1% decline as a measured figure, so the commercial effect is demonstrated rather than inferred, and it bears directly on the decision the claim is used to justify. The claim reports only the upgrade gain and omits the revenue effect, so as written it is incomplete in a way that would change the decision. If the objection were resolved against the claim, the pricing would stand as recommended; nothing supplied resolves it, so the recommendation needs the revenue effect stated and weighed."

overall_result:
  result: revise
  statement: "The upgrade increase is not explained by the competitor outage: the incident predates the change and the upgrade trend was already rising for eight months beforehand. The attribution of the increase to the pricing change is not refuted by this audit, though no holdout was supplied and it remains unestablished rather than demonstrated. What the claim omits is the other side of the trade: revenue per enterprise account fell 3.1 percent across the change, a measured effect that bears directly on whether to hold the pricing. The claim should be restated to carry both figures so the decision can be made on the trade rather than on the gain alone."
  objections_supporting_result:
    - O2
  basis:
    - "E1, E2, and E3 refute the outage explanation on timing and shape"
    - "E4 establishes the revenue-per-account decline as a measured quantity"
    - "no holdout or elasticity estimate was supplied, so the causal attribution to the price change itself stays unresolved"

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
  disclosure: "All passes ran in one model in one conversation and are correlated. No pass was counted as evidence, and both findings rest on cited records rather than on the model's judgment. No external source was consulted and no adjudicator participated."

limitations:
  - "No external research was performed or authorized, so the competitor incident timeline was not independently corroborated."
  - "The upgrade increase is not attributed to the pricing change by this audit either. O1 refutes one alternative, not all alternatives, and with no holdout the causal attribution remains unresolved. Refuting an objection is not confirming the claim."
  - "enterprise account is undefined in the supplied documents, so the population boundary could not be checked."
  - "The revenue-per-account decline is measured but not decomposed into price, mix, and expansion, so its cause is unknown. What is established is that the decline occurred, not why."
```

## The distinction this file protects

O1 and O2 point in opposite directions, and the protocol reports both without one
suppressing the other. Refuting an objection is not confirming a claim, and that
is the sentence most worth reading twice: **this audit refuted the outage
explanation and still returned `revise`**, because an objection elsewhere was
supported by a measurement the claim had left out.