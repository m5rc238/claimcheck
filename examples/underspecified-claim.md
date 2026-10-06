# Example: materially underspecified claim, audited early

**What this exercises.** The stop rule. When the claim is too vague for the
question to have a determinate answer, the correct output is a request for
clarification — not a long, confident list of objections to a target that does not
exist yet.

> All data and figures in this file are synthetic and illustrative.

## Input

**Claim.** "AI improves customer support quality."

**Supplied.** Nothing beyond the sentence above.

## Why this stops

Three of the six formalization slots are empty in ways that change *which
objections apply*, not merely how they read:

- **Population** — customers? agents? both? which segment?
- **Predicate** — "improves" by what measure, judged against what baseline?
- **Timeframe** — first contact? thirty days? a quarter?

Under one reading ("AI drafts replies, measured by handle time and CSAT"), the
live objection is a hallucination risk. Under another ("AI triages tickets by
priority"), the live objection is mis-prioritisation and the hallucination risk is
not the issue at all. Objections generated before this is fixed would be a
plausible-sounding mixture of both, with no way for the reader to tell which
apply.

So the protocol stops. That is the correct outcome here, not a failure to find
problems.

## Record

```yaml
claim:
  original: "AI improves customer support quality."
  subject: 'unspecified; the term "AI" is not identified as a system, feature, or workflow'
  predicate: 'the word "improves" names no measure and no baseline'
  scope: 'the phrase "customer support" is not bounded to a channel, team, or workflow step'
  population: absent; the beneficiary of the improvement is not stated
  timeframe: absent; no measurement window is given
  baseline: absent; no comparison is stated
  intended_interpretation: not stated, and not recoverable from the sentence
  dependent_decision: not stated
  missing_definitions:
    - "which AI system or workflow step is meant"
    - "what measure constitutes support quality"
    - "which population benefits and which is measured"
    - "over what timeframe quality is assessed"
    - "the baseline the improvement is measured against"
  load_bearing_assumptions:
    - "none recoverable; the claim asserts a comparison without stating either side"
  formalization_status: underspecified

scope:
  in_scope:
    - "determining whether the claim can be audited at all"
  out_of_scope:
    - "every substantive objection, which cannot yet be assessed for applicability"
  evidence_cutoff: null

evidence_boundary:
  available_evidence: []
  unavailable_evidence:
    - "any description of the AI system in use"
    - "any definition of support quality"
    - "any baseline measurement"
    - "any prior or current support metrics"
  background_knowledge:
    role: hypothesis_generation_only
    used_for:
      - "nothing; the protocol stopped before candidate generation"
  external_research: unavailable

candidate_objections: []

overall_result:
  result: underspecified_claim
  statement: "The claim cannot be audited as written, and no objections were generated. It names no system, no measure of quality, no population, no timeframe, and no baseline, and at least two of the missing details change which objections would apply: under a drafting-assistant reading the material risk is fabricated content, while under a triage reading it is mis-prioritisation, and nothing in the sentence distinguishes them. Five clarifications are listed below. Once the measure, population, and comparison are fixed, this protocol can be rerun and will likely find a real problem worth finding."
  objections_supporting_result: []
  basis:
    - "no evidence was supplied, so no objection could be tested even if one had been generated"
    - "the missing definitions are listed in claim.missing_definitions"

clarifications_required:
  - "Which AI system or workflow step is in use, and what does it do?"
  - "What measure is used for support quality, and who is measured?"
  - "Which population is affected - customers, agents, or both?"
  - "Over what timeframe is quality assessed?"
  - "What is the baseline the improvement is measured against?"

evaluator_error:
  ground_truth_available: false
  ground_truth_source: null
  evaluator_error_rate: evaluator_error_rate_not_determinable

independence:
  passes_performed:
    - "claim formalization"
    - "formalization adequacy check"
  independent_judgments: false
  disclosure: "Only the formalization steps ran. No objection was generated, tested, or anti-red-teamed, and no model judgment bears on the substance of the claim. Nothing here is corroborated, and had an objection been raised it would have been tested by the same model in the same conversation, with the same priors. The early exit reflects an absence of information rather than a finding."

limitations:
  - "This record reports an absence of evaluable content. It is not a finding that the claim is sound, nor that it is unsound."
  - "No evidence was supplied and external research was not authorized, so no attempt was made to reconstruct the intended meaning."
  - "Whether the claim is materially underspecified or merely vaguely worded is itself a judgment. The test applied was whether plausible readings yield different sets of applicable objections, and here they clearly do."
  - "A user who supplies the five clarifications may still end up with no supported problem. This early exit is not a prediction that problems exist."
```

## What to notice

**`candidate_objections` is empty, and that is the finding.** A protocol that
produced eight objections here would be performing the role rather than doing the
work. The empty list is not a gap in the audit; it is the audit.

**The stop rule has a test, not a vibe.** The claim is *materially*
underspecified because plausible readings produce *different applicable
objection sets* — hallucination risk versus mis-prioritisation. A claim that is
merely imprecise, where every reading yields the same objections, proceeds to
testing with the imprecision logged as a `minor_limitation`. The distinction is
in `protocol.md` § Step 1.

**The statement says the problem may well be real.** "Once the measure,
population, and comparison are fixed… this protocol can be rerun and will likely
find a real problem worth finding." An early exit is not a pass. Protocols that
treat "not enough to assess" as "nothing wrong" have just invented a null result,
which is the mirror image of the failure this repository is about.

**`evidence_boundary.available_evidence` is empty and honest.** A record that
listed plausible-sounding supporting material here would be fabricating a source.
The `unavailable_evidence` list is doing real work: it names what would have to be
supplied.

**No objections were generated, so none were mis-classified.** Note what this buys:
no `supported` status was issued without evidence, because no status was issued at
all.