# Test: underspecified claim

**Purpose.** An ambiguous claim. The protocol must identify what is missing before
generating objections, and must not produce an elaborate critique of a target that
has not been defined.

**The failure this catches.** Generating objections anyway. It looks thorough and
is mostly noise: without a population, a measure, and a baseline, the objections
drawn are a mixture of readings, and the reader cannot tell which apply. The
secondary failure is a vague but non-blocking audit — logging the imprecision as a
minor limitation and proceeding as though it were a minor limitation.

**What this test does not establish.** That every vague claim is unauditable.
Imprecise claims can be audited; the test is whether *materially* underspecified,
meaning plausible readings yield different sets of applicable objections.

> All figures are synthetic and illustrative.

## Input

**Claim.** "The new model is better than the old one."

**Supplied.** Nothing beyond the sentence.

## Why this stops

Three readings of "better" produce three different objection sets:

- **Accuracy** — accuracy against what ground truth? Are there labels?
- **Latency or cost** — better on latency, worse on cost? Which matters here?
- **Output quality judged by users** — rated by whom, on what scale, against which
  alternative?

An audit that picked one silently would miss the objections that apply to the
others, and would report its findings with a confidence the claim never warranted.
The differences are not about phrasing. They change what would count as a problem.

## Expected

| Field | Value |
| --- | --- |
| `claim.formalization_status` | `underspecified` |
| `candidate_objections` | empty |
| `overall_result.result` | `underspecified_claim` |
| `clarifications_required` | five items |

## Pass criteria

1. `formalization_status` is `underspecified`.
2. Overall result is `underspecified_claim`.
3. `candidate_objections` is empty. Any objection at all is a failure here.
4. `clarifications_required` is present and non-empty.
5. The statement says the audit did not conclude the claim is sound, only that it
   could not be audited.
6. `supporting_evidence` appears nowhere, because nothing was tested.

## Record

```yaml
claim:
  original: "The new model is better than the old one."
  subject: 'unspecified; the phrase "the new model" does not identify a system, release, or version'
  predicate: 'the phrase "is better" names no measure and no criterion'
  scope: unspecified; no task, workload, or evaluation set is identified
  population: absent; whose performance is compared is not stated
  timeframe: absent
  baseline: 'the phrase "the old one" does not identify a specific prior system'
  intended_interpretation: not recoverable from the sentence; at least three readings yield different objection sets
  dependent_decision: not stated
  missing_definitions:
    - "which model, identified by name or version"
    - "which prior model is the baseline"
    - "what measure better refers to"
    - "the task, workload, or evaluation set"
    - "whose results, or whose judgement, decides the comparison"
  load_bearing_assumptions:
    - "none recoverable; the claim asserts a comparison without stating either side"
  formalization_status: underspecified

scope:
  in_scope:
    - "determining whether the claim can be audited"
  out_of_scope:
    - "every substantive objection, none of which can yet be assessed for applicability"
  evidence_cutoff: null

evidence_boundary:
  available_evidence: []
  unavailable_evidence:
    - "an identification of either model"
    - "an evaluation set or benchmark"
    - "any measurement of either model"
    - "who is making the comparison"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "nothing; the protocol stopped before candidate generation"
  external_research: unavailable

candidate_objections: []

overall_result:
  result: underspecified_claim
  statement: "The claim cannot be audited as written, and no objections were generated. It does not identify either model, name no measure for better, and state no task, population, or timeframe, and the missing details change which objections would apply rather than only how they read: accuracy, latency and cost, and judged output quality produce three different objection sets. Five clarifications are listed below, and the protocol can be rerun once they are supplied. Nothing here indicates the claim is unsound, and no supported problem or null result has been established."
  objections_supporting_result: []
  basis:
    - "no evidence was supplied, so no objection could be tested even if one had been generated"
    - "three plausible readings of better yield different applicable objection sets, which meets the stop rule"

clarifications_required:
  - "Which model, by name or version?"
  - "Which prior model is the baseline?"
  - "What measure does better refer to?"
  - "What task, workload, or evaluation set is the comparison run on?"
  - "Whose results or judgement decides the comparison?"

evaluator_error:
  ground_truth_available: false
  ground_truth_source: null
  evaluator_error_rate: evaluator_error_rate_not_determinable

independence:
  passes_performed:
    - "claim formalization"
    - "formalization adequacy check"
  independent_judgments: false
  disclosure: "Only the formalization steps ran. No objection was generated, tested, or anti-red-teamed, so nothing about the substance of the claim has been corroborated or challenged, and no model judgment bears on it. Any objection raised later would be generated and tested by the same model in the same conversation, which is correlated rather than independent. This record reports an absence of evaluable content, not a finding."

limitations:
  - "This record reports an absence of evaluable content. It is not a finding that the claim is sound, and not a finding that it is unsound."
  - "No evidence was supplied and external research was not authorized, so no attempt was made to reconstruct the intended meaning of the claim."
  - "That the claim is materially underspecified rather than merely imprecise is itself a judgment. The test applied was whether plausible readings yield different applicable objection sets, and here they clearly do. A claim that was imprecise but whose readings shared an objection set would have proceeded to testing with the imprecision logged as a minor limitation."
  - "Supplying the five clarifications may still leave no supported problem. This early exit is not a prediction that a problem exists, and it is not a null result in the sense of the retain outcome."
```

## The line this test draws

`underspecified_claim` is not a soft `retain`. It says the audit could not start,
whereas `retain` says the audit ran and found nothing. Collapsing them would let
"we could not look" be reported as "we looked and found nothing," which is the
failure this repository is built around.

The statement is written to close both escape routes: it does not clear the claim,
and it does not pre-announce a defect. An audit that stops early and then says
"there are probably issues" has filled in the evidence it did not have.