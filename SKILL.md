---
name: epistemic-redteam
description: "Audit a claim and any AI-generated critique of it against evidence, producing a structured, auditable record instead of a list of objections. Use when asked to red-team, critique, challenge, stress-test, sanity-check, verify, poke holes in, or find weaknesses in a claim, analysis, conclusion, model output, research finding, product decision, or argument - and whenever someone asks whether something is actually true, supported, overstated, or safe to act on. Also use when a critique itself needs auditing, when a previous critique is being treated as authoritative, or when a claim may be defended, narrowed, or investigated rather than merely attacked. Triggers on red team, red-team, critique, criticize, challenge this, what is wrong with, poke holes, stress test, fact check, verify this claim, is this sound, adversarial review, devil's advocate, claim audit, epistemic audit."
license: MIT
version: 1.0.0
---

# Epistemic Red-Team

An evidence-calibration protocol for auditing claims and critiques. Use it
whenever a claim needs challenging, and whenever a critique needs auditing.

> A critique is itself a claim, and must be auditable like one.

The failure this prevents is the quiet one. Asked to "find weaknesses", a model
will find weaknesses - whether or not the evidence supports them. A plausible
objection, stated fluently, is indistinguishable from a real defect unless
something forces the two apart. This protocol supplies that something: an
evidence boundary, an audit trail, and a reporting vocabulary in which "no
supported problem identified" is a legitimate and complete result.

## When to use this skill

- Auditing a claim, analysis, conclusion, or model output before acting on it.
- Auditing a critique produced by a model, a colleague, or an automated reviewer.
- Deciding between revising a claim, investigating it, and retaining it.
- Checking whether a "finding" rests on evidence or on plausibility.
- Any request framed as "find weaknesses", "what's wrong with this", or "red team
  this" - where the default failure is manufactured objections.

## Do not use this skill to

- maximize the number of objections, or to perform skepticism as an identity;
- reach a specific verdict the user has already decided on;
- substitute for empirical testing, primary sources, or expert adjudication
  where those are available and decisive;
- produce a score, rating, or red-team number as the headline result;
- certify that a claim is true because nothing was found against it.

## Priority rules

Always in force. Everything below is technique, not obligation.

1. **Formalize before critiquing.** No objections until subject, predicate,
   scope, population, timeframe, baseline, and dependent decision are fixed.
2. **Declare the evidence boundary first.** Available evidence and background
   knowledge are separate pools, and they never merge.
3. **Background knowledge may generate objections, never support them.** It may
   never be cited as evidence in either column — but supplied evidence *may*
   refute a background-knowledge objection, which is how that objection becomes
   `contradicted`. Only the supporting direction is forbidden.
4. **No silent escalation.** `possible → likely → supported → demonstrated`
   requires a named locator at each rung.
5. **A candidate objection is not a problem.** Label candidates as candidates.
6. **Anti-red-team concretely.** Name the observation that would falsify the
   objection. A generated counterargument is not that observation.
7. **Risk is not defect.** Classify evidence status and problem status
   separately, every time.
8. **Materiality requires a counterfactual**, not a feeling of importance.
9. **`revise` requires the full chain**: supported + substantive problem +
   material.
10. **Null results are reportable.** `retain` is a real answer, stated as
    "no supported problem identified from the available evidence".
11. **Multiple passes are not independent evidence.** Disclose it every run.
12. **Confidence is in the evaluation**, bounded by evidence, never in the claim.

## Execution procedure

Run in order. Each step's output feeds the next.

### 1. Formalize the claim

Extract: original claim (quoted), subject, predicate, scope, population,
timeframe, baseline, intended interpretation, the decision that depends on it,
missing definitions, load-bearing assumptions.

**Stop rule.** If the claim is *materially* underspecified — the missing
information would change which objections apply, not just how they read — return
`overall_result: underspecified_claim`, list what to clarify, and stop. Do not
generate elaborate objections against an undefined claim; they are usually noise
wearing the costume of rigor.

Imprecision is not underspecification. If every plausible reading yields the same
applicable objections, proceed and log the imprecision as a `minor_limitation`.

### 2. Establish the evidence boundary

Split everything you may use into **available evidence** (supplied documents,
data, quotes, cited sources actually provided, experiments run for this audit,
explicitly authorized external sources) and **background knowledge** (domain
facts, methodological norms, expectations).

Record what is unavailable. Record whether external research was authorized,
attempted, or unavailable — and never imply a search happened when it did not.

### 3. Generate candidate objections

Label every objection `candidate_objection`. Each gets: the objection, why it
might matter, its basis (`supplied_evidence` / `background_knowledge` / `mixed`),
what evidence would support it, what would contradict it, a resolution test, and
an inapplicability condition.

**Do not generate objections because they are common criticisms of this kind of
claim.** Template objections are the main source of false positives. If you
cannot state when the objection would *not* apply, delete it.

### 4. Test each objection against evidence

For each candidate, write the answers: what evidence supports it (with
locators), what contradicts it (with locators), whether it actually applies to
*this* claim, whether it rests on supplied evidence or on general possibility,
and what would resolve it. Empty evidence lists are the correct answer far more
often than they feel.

### 5. Anti-red-team the objection

Try to falsify the objection itself. Write the concrete observation, source,
calculation, experiment, or supplied context that would show it wrong. Then check
whether such evidence is in the boundary.

If nothing in the boundary distinguishes the objection from its rejection,
classify `unresolved` or `unsupported`. Do not treat the ability to generate a
counterargument as a resolution — and never treat generated reasoning as
evidence, including your own reasoning from earlier in this run.

### 6. Classify: exactly one primary status

- `supported` — evidence meaningfully supports the objection.
- `contradicted` — evidence meaningfully conflicts with it.
- `unsupported` — plausible, but unsupported. **This is not "false".**
- `unresolved` — material, but the available information cannot settle it.
- `not_applicable` — does not apply to this claim or context.

Never use "rejected" as a synonym for "false."

### 7. Separate risk from demonstrated problem

Classify two independent axes:

- **evidence_status**: `demonstrated` / `supported` / `possible` / `unknown`
- **problem_status**: `substantive_problem` / `meaningful_risk` /
  `minor_limitation` / `no_demonstrated_problem`

The distinction that matters: *"the sample may not represent the target
population"* is a legitimate methodological **risk**; it does not establish *"the
study has an invalid sample."* The first is `possible` + `meaningful_risk`. The
second is `demonstrated` + `substantive_problem`. Repetition does not promote a
risk into a defect.

### 8. Assess materiality

Would resolving this change the claim's truth, scope, warranted confidence, the
decision, or the interpretation? Classify `material`, `potentially_material`, or
`immaterial`.

**`material` requires a named counterfactual**: what would change if the
objection were resolved against the claim. An objection is not material because
it sounds serious.

### 9. Decide impact

`revise` / `investigate` / `retain` / `no_effect`, derived from status +
evidence_status + problem_status + materiality + decision context.

`revise` requires **all** of: `supported`, `substantive_problem`, `material`.
Anything weaker is `investigate`, `retain`, or `no_effect`. Never revise a claim
merely because an objection to it exists.

### 10. Produce the overall result

`revise` / `investigate` / `retain` / `uncertain` / `underspecified_claim`, plus a
plain-language statement.

**`retain` means exactly this:**

> No supported problem identified from the available evidence.

Not "the claim is validated." Not "proven." Not "confirmed." Not "no issues
found." The evidence boundary is part of the sentence's meaning; drop the
boundary and the sentence overstates.

## Output

Emit the record defined in `schema.md`. Then add, in plain language:

- what was found, in one paragraph;
- the single most important limitation;
- what would change the result, if known.

Do not add a score. Do not add a red-team rating. Structured reasoning is the
output.

## Mandatory disclosures in every result

1. **Non-independence.** Model passes are not independent evidence. A second
   model is not ground truth. Self-critique reproduces the evaluator's own
   blind spots.
2. **No ground truth.** Unless real ground truth was part of the audit, report
   `evaluator_error_rate: evaluator_error_rate_not_determinable`. The evaluator's
   own agreement is not ground truth, and a null result is not a true negative
   unless something external says so.
3. **Evidence boundary.** Which evidence was available, which was not, and
   whether external research happened.
4. **What this protocol does not do.** It improves auditability and calibration.
   It does not make the evaluator correct.

## Calibration and evaluator error

Relative to ground truth: TP = real problem correctly supported; FP = non-problem
wrongly supported (**the characteristic failure of a red-team evaluator**); TN =
non-problem not treated as supported; FN = real problem missed or filed as
`unsupported`. Precision = TP/(TP+FP); recall = TP/(TP+FN); calibration = whether
stated confidence tracks correctness.

All four require ground truth — empirical testing, authoritative evidence,
reproducible calculation, expert adjudication, benchmark labels, or subsequent
outcomes. Without it, report
`evaluator_error_rate_not_determinable`. Do not invent a rate.

A red-team framing biases toward false positives. This protocol addresses that
bias by making null results reportable and by forbidding evidence-free
escalation. It does not measure the bias, and it does not eliminate it.

## Failure modes to watch for in your own output

- Manufacturing objections to fill a role. If nothing survives testing, say so.
- Upgrading a methodological worry into a claimed defect.
- Citing background knowledge as if it were supplied evidence.
- Treating "I could not find a counterargument" as confirmation.
- `retain` phrased as validation.
- A confident rationale standing in for absent evidence.
- Fogging `unsupported` into "not true".
- High confidence because the explanation sounded good.

## Final verification contract

Before returning, re-read `protocol.md` § 7 and check all twelve items. Any "no"
is a defect to repair first. Report the check; do not claim the audit passed
merely because it completed.