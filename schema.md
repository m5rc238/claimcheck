# Schema for an auditable critique

Machine-readable shape of a critique record, the permitted values, and the
consistency rules that bind them. `protocol.md` is normative for meaning; this
file is normative for structure.

## 1. Record shape

```yaml
claim:
  original: <string, quoted>          # required
  subject: <string>                    # required
  predicate: <string>                  # required
  scope: <string>                      # required
  population: <string>                 # required
  timeframe: <string>                  # required
  baseline: <string | null>            # required key, may be null
  intended_interpretation: <string>    # required
  dependent_decision: <string>         # required
  missing_definitions: [<string>]      # required, may be empty
  load_bearing_assumptions: [<string>] # required, may be empty
  formalization_status: sufficient | underspecified   # required

scope:
  in_scope: [<string>]
  out_of_scope: [<string>]
  evidence_cutoff: <string | null>

evidence_boundary:
  available_evidence:
    - ref: <string>                    # unique within the run
      type: user_provided | document | dataset | experiment | cited_source |
            authorized_external
      locator: <string>                # how to re-check it
      content: <string>                # the observation itself
  unavailable_evidence: [<string>]
  background_knowledge:
    role: hypothesis_generation_only    # fixed value
    used_for: [<string>]               # which candidate objections it prompted
  external_research: authorized | attempted | unavailable | not_authorized

candidate_objections:
  - id: <string>                       # unique within the run
    objection: <string>                # required
    why_it_might_matter: <string>      # required
    basis: supplied_evidence | background_knowledge | mixed   # required
    supporting_evidence: [<evidence_ref>]
    contradicting_evidence: [<evidence_ref>]
    resolution_test: <string>          # required: the concrete observation
    inapplicability_condition: <string> # required
    status: supported | contradicted | unsupported | unresolved | not_applicable
    evidence_status: demonstrated | supported | possible | unknown
    problem_status: substantive_problem | meaningful_risk | minor_limitation |
                   no_demonstrated_problem
    materiality: material | potentially_material | immaterial
    decision_impact: revise | investigate | retain | no_effect
    confidence: low | medium | high    # confidence in THIS classification
    rationale: <string>                # required

overall_result:
  result: revise | investigate | retain | uncertain | underspecified_claim
  statement: <string>                  # plain language, not overstated
  objections_supporting_result: [<objection_id>]
  basis: [<string>]

# Optional. Permitted only when overall_result.result is underspecified_claim.
clarifications_required: [<string>]    # what the user must supply to proceed

# Optional. Permitted on any objection. Use when the record needs to explain
# something a status alone cannot carry, such as evidence cited on both sides.
resolution_note: <string>

evaluator_error:
  ground_truth_available: true | false
  ground_truth_source: <string | null>
  evaluator_error_rate: evaluator_error_rate_not_determinable | <string>

independence:
  passes_performed: [<string>]
  independent_judgments: false | true  # true only with external ground truth
  disclosure: <string>                 # required, non-independence statement

limitations:
  - <string>
```

An `evidence_ref` is:

```yaml
- ref: <string>                        # must match an entry in available_evidence
```

## 2. Permitted values

`status` — exactly one, per objection:

| Value | Meaning | Not a synonym for |
| --- | --- | --- |
| `supported` | Evidence meaningfully supports the objection. | — |
| `contradicted` | Evidence meaningfully conflicts with it. | — |
| `unsupported` | Plausible; evidence does not support it. | "false" |
| `unresolved` | Material; available information cannot settle it. | "probably fine" |
| `not_applicable` | Does not apply to this claim or context. | "unsupported" |

`evidence_status` — how well the evidence settles the matter:
`demonstrated`, `supported`, `possible`, `unknown`.

`problem_status` — what kind of thing it is: `substantive_problem`,
`meaningful_risk`, `minor_limitation`, `no_demonstrated_problem`.

`materiality`: `material`, `potentially_material`, `immaterial`.

`decision_impact`: `revise`, `investigate`, `retain`, `no_effect`.

`confidence`: `low`, `medium`, `high` — in the evaluation only.

## 3. Consistency rules

These are the rules that keep the three axes from collapsing into one another.
`tests/check-consistency.rb` enforces R1–R13 mechanically, with R8
approximated by a heuristic (see its note).

### R1 — `status` and `evidence_status` must agree

| `status` | Permitted `evidence_status` |
| --- | --- |
| `supported` | `demonstrated`, `supported` |
| `contradicted` | `demonstrated`, `supported` |
| `unsupported` | `possible`, `unknown` |
| `unresolved` | `unknown` |
| `not_applicable` | `unknown` |

`supported` + `possible` is forbidden: it would mean the objection is endorsed on
the strength of a possibility.

### R2 — `status: supported` requires evidence

`status: supported` requires a non-empty `supporting_evidence`. Same for
`contradicted` and `contradicting_evidence`. Plausibility is not a warrant.

### R3 — `status: unsupported` must not carry supporting evidence

An objection with `status: unsupported` and a non-empty `supporting_evidence` is
inconsistent. If evidence supports it, its status is `supported`.

### R4 — evidence locators must exist in the boundary

Every entry in `supporting_evidence` and `contradicting_evidence` must match a
`ref` in `evidence_boundary.available_evidence`. No unlocatable evidence.

### R5 — background knowledge may not support an objection

| `basis` | Constraint |
| --- | --- |
| `background_knowledge` | `supporting_evidence` must be empty. `contradicting_evidence` may be populated. |
| `mixed` | `supporting_evidence` must be non-empty. |
| `supplied_evidence` | At least one evidence list must be non-empty. |

Background knowledge may *generate* an objection and may not *support* one. A
generated objection that supplied evidence then refutes is the normal and correct
case, so `contradicting_evidence` is permitted under a `background_knowledge`
basis (`protocol.md` § 3.1). What is forbidden is background knowledge appearing
in the supporting column, and R4 already prevents it appearing anywhere, since
every cited ref must resolve to a boundary entry.

### R6 — substantive problems require demonstration

`problem_status: substantive_problem` requires `evidence_status: demonstrated`.

A risk is not a defect. `possible` + `substantive_problem` is forbidden.

### R7 — a substantive problem cannot be immaterial

| Constraint | Reason |
| --- | --- |
| `problem_status: substantive_problem` forbids `materiality: immaterial` | A problem that demonstrably affects the claim is not, by definition, immaterial to it. |
| `materiality: immaterial` restricts `decision_impact` to `retain` or `no_effect` | An immaterial finding does not warrant investigation or revision. |

Note what R7 does **not** say: `evidence_status: demonstrated` does not imply
`materiality: material`. A `contradicted` objection is `demonstrated` in the sense
that the evidence settled it, and it is routinely `immaterial` — the objection
turned out to have no bearing on the claim. Confusing "demonstrated" with
"demonstrated *problem*" is exactly the collapse this protocol exists to
prevent.

### R8 — materiality needs a counterfactual

`materiality: material` requires the `rationale` to name the consequence: what
would change in the claim, its scope, the warranted confidence, the decision, or
the interpretation if the objection were resolved against the claim (the
counterfactual rule in `protocol.md` § Step 8).

This is the one rule the automated checker can only approximate: it flags a
`material` classification whose rationale contains no consequence marker
(`would`, `consequence`, `if the`, `changes`). The flag is a heuristic prompt for
review, not a proof of violation. Severity-sounding language with no consequence
clause is the real failure mode, and it is caught by reading.

### R9 — required fields are non-empty

`objection`, `why_it_might_matter`, `resolution_test`,
`inapplicability_condition`, `rationale` must be non-empty strings.

`rationale` is checked for substance: it must be at least 12 words. One-word
rationales are how unsupported conclusions pass review.

### R10 — `revise` requires the full chain

`decision_impact: revise` requires `status: supported` **and**
`problem_status: substantive_problem` **and** `materiality: material`. Any
weaker combination yields `investigate`, `retain`, or `no_effect`.

### R11 — confidence is bounded by evidence

`confidence: high` requires `evidence_status` in {`demonstrated`, `supported`} and
a non-empty `supporting_evidence` (or `contradicting_evidence` for
`contradicted`). High confidence with weak or absent evidence is a protocol
violation.

### R12 — `retain` forbids validation language

If `overall_result.result` is `retain`, `overall_result.statement` must contain
"No supported problem identified" (case-insensitive) and must not contain any of:

`proven`, `proves`, `validate`, `validated`, `confirms`, `confirmed`, `verifies`,
`verified`, `correct`, `true`, `accurate`, `no issue found`, `flawless`, `beyond
doubt`, `definitively`.

Matching is on word boundaries, so `incorrect` does not trip the `correct` rule
(`incorrect` describes something being wrong, not a claim being validated).

The banned list is a lexical backstop, not a substitute for care. A `retain`
statement must also not imply validation by other phrasing — "the claim holds up",
"it survived scrutiny", "nothing suggests otherwise", "withstood the challenge".
The checker greps for a handful of these paraphrases and reports them as
warnings, since a phrase it has not thought of will pass silently. The standard is
the sentence's meaning, not the word list.

### R13 — `not_applicable` implies no bearing on the claim

`status: not_applicable` requires `materiality: immaterial`,
`decision_impact: no_effect`, and
`problem_status: no_demonstrated_problem`. A gap in the evidence is not an
objection to the claim, and recording it as one is how scope boundaries become
fabricated findings. Record the gap in `limitations` or `scope.out_of_scope`
instead.

## 4. Aggregations

### 4.1 Optional field gating

`clarifications_required` is permitted only when `overall_result.result` is
`underspecified_claim`, and is required in that case. `resolution_note` is
permitted on any objection.

### 4.2 Overall result derivation

| `result` | Requires |
| --- | --- |
| `revise` | ≥1 objection with `decision_impact: revise`. |
| `investigate` | No `revise`, and ≥1 objection with `decision_impact: investigate`. |
| `uncertain` | Evidence too incomplete or conflicting for a reliable conclusion; state why. |
| `retain` | No objection with `decision_impact` of `revise` or `investigate`. |
| `underspecified_claim` | `claim.formalization_status: underspecified`. |

`retain` and `uncertain` may co-occur as a judgement about different aspects; if
they do, the record must say which aspects, and `uncertain` wins the field only
when it applies to the overall conclusion.

### 4.3 Independence disclosure

`independence.independent_judgments` is `false` for any run that uses only model
passes. It may be `true` only when an external ground truth (empirical test,
authoritative source, reproducible calculation, expert adjudication, benchmark
label) was part of the audit — and `evaluator.ground_truth_source` must name it.

### 4.4 Evaluator error

`evaluator_error_rate` must be `evaluator_error_rate_not_determinable` unless
`ground_truth_available` is `true` and `ground_truth_source` is non-null.

## 5. Deliberately not included

No score. No weighted total. No red-team rating. No severity index.

Structured reasoning is the output; a number would compress exactly the
distinctions — risk versus demonstrated problem, unsupported versus contradicted,
no-problem-found versus claim-validated — that the protocol exists to preserve,
and would hide them behind a single magnitude.