# Protocol: Evidence-Calibrated Critique

Normative specification. Where any other file in this repository disagrees with
this one, this file wins.

## 0. Purpose and non-goals

**Purpose.** Determine whether a substantive problem with a claim is actually
supported by evidence inside a declared boundary, and record the judgment so a
third party can audit it.

**Non-goals.** This protocol does not:

- maximize the number of objections produced;
- make the evaluator more skeptical, more cautious, or more agreeable;
- produce a single score or ranking;
- certify that a claim is true;
- certify that the evaluator's own judgment is correct.

A run that finds nothing is a valid, expected outcome. A run that produces many
objections is not evidence of a thorough audit.

---

## 1. Terminology

These words are defined here and used consistently across every file. The
distinctions are the point of the protocol; collapsing them is the primary
failure mode.

| Term | Definition | Not this |
| --- | --- | --- |
| **Observation** | Something perceived or recorded in a source: a number, a quote, a logged event. | An interpretation of one. |
| **Evidence** | An observation bearing on the claim, with a locator, that a reader can re-check. | Something merely plausible. |
| **Source** | The origin of an evidence item: a document, dataset, test, interview, or measurement. | A citation that was not actually consulted. |
| **Inference** | A conclusion drawn from evidence. | An observation. Never cite an inference as evidence. |
| **Assumption** | A premise taken as true without evidence in the boundary. | Evidence. |
| **Hypothesis** | A candidate explanation that may account for evidence. | A finding. |
| **Candidate objection** | A proposed problem, not yet tested against evidence. | A demonstrated problem. |
| **Uncertainty** | A state in which the evidence does not settle the question. | A deficit to be filled by more eloquent reasoning. |
| **Decision** | What a reader should do given the finding and their own stakes. | The finding itself. |
| **Revision** | An actual change to the claim, interpretation, or decision. | A recorded intention to change one. |

**Grounding rules.**

1. An inference is never recorded as an observation or as evidence.
2. A possibility is never recorded as evidence.
3. Fluency is not corroboration. A claim does not gain support because the
   evaluator can explain why it sounds right.
4. Never invent a source, locator, quotation, or number. If a source was not
   supplied, it does not exist for the purposes of this run.
5. If external research was not performed, record
   `external_research: unavailable` and say so in the plain-language summary.
   Do not imply a search happened.

### 1.1 Terms defined by this project, not by prior literature

The phrase **"false skepticism"** used in this repository is this project's own
terminology for *objections produced by an evaluator in order to satisfy the
role it was asked to play, without evidentiary support*. It is descriptive
vocabulary, not a citation to any established research term.

For prior work, use the established terms: LLM-as-a-judge, evaluator
reliability, evaluator bias, false positives, false negatives, calibration,
judge instability, imperfect evaluation. No literature is cited in this
repository, because none has been verified; see `README.md` § Limitations.

---

## 2. Workflow

Ten steps, in order. Each step consumes the previous step's output. Do not
reorder them: objections generated before the evidence boundary is declared will
smuggle background knowledge in as evidence.

```
Claim
→ Scope
→ Evidence boundary
→ Candidate objections
→ Evidence testing
→ Anti-red-team
→ Classification
→ Materiality
→ Decision impact
→ Overall result
```

### Step 1 — Formalize the claim

Extract before critiquing. Record:

- the original claim, quoted;
- subject, predicate, scope;
- population, timeframe, comparison or baseline;
- the intended interpretation (what the claimant takes it to mean);
- the decision or conclusion that depends on the claim;
- missing definitions (undefined terms that carry argumentative weight);
- load-bearing assumptions.

**Stop rule.** If the claim is *materially* underspecified — the missing
information would change which objections are applicable, not merely how they are
phrased — return `overall_result: underspecified_claim`, list what must be
clarified, and stop. Do not generate elaborate objections against an undefined
claim. Elaborate objections against an undefined claim are usually noise, and
presenting them creates false confidence in the audit.

Mere imprecision is not underspecification. If all plausible readings of the
claim yield the same set of applicable objections, proceed and note the
imprecision as a `minor_limitation`.

### Step 2 — Establish the evidence boundary

Partition everything the critique may use:

- **Available evidence** — supplied by the user: documents, data, quoted text,
  cited sources that were actually provided, results of experiments run for this
  audit, and external sources the user explicitly authorized.
- **Background knowledge** — the evaluator's own knowledge: domain facts,
  methodology norms, expectations about what usually happens.

**Promotion rule.** Background knowledge may generate candidate objections. It
may never be *cited* — not in an objection's `supporting_evidence`, not in its
`contradicting_evidence`. That is a rule about the *source* of a citation, and
R4 enforces it mechanically: every cited ref must resolve to a boundary entry.

One consequence is easy to get backwards. A background-knowledge objection may be
*refuted by supplied evidence*. Nothing stops E2 from contradicting an objection
that background knowledge proposed — the objection was generated from the model's
own knowledge, and the supplied evidence settles it. Such an objection records
`basis: background_knowledge`, `contradicting_evidence: [E2]`, and
`status: contradicted`. What is forbidden is background knowledge *supporting* an
objection. Refutation is not support.

An objection whose basis is background knowledge and which nothing refutes is
usually `unsupported` — a correct and complete finding, not a failure to perform
the role.

Record explicitly: what is unavailable, and whether external research was
authorized, attempted, or unavailable.

### Step 3 — Generate candidate objections

Generate objections, label every one `candidate_objection`, and give each:

- `objection` — the proposed problem, one sentence;
- `why_it_might_matter` — the mechanism by which it would affect the claim;
- `basis` — `supplied_evidence`, `background_knowledge`, or `mixed`;
- `supporting_evidence` — empty at this stage; you have not looked yet;
- `contradicting_evidence` — empty at this stage;
- `resolution_test` — what observation would settle it;
- `inapplicability_condition` — what would make this objection not apply.

**Prohibition.** Do not generate an objection because it is a common criticism of
this *type* of claim. Template objections are the main source of false positives.
An objection must be tethered to something in this claim, this scope, or this
evidence. If you cannot state the applicability condition, drop it.

### Step 4 — Test each objection against evidence

For each candidate, answer in writing:

1. What evidence supports it? Cite locators.
2. What evidence contradicts it? Cite locators.
3. Is it actually applicable to *this* claim, or merely to claims of this shape?
4. Is it based on supplied evidence, or on general possibility?
5. What evidence would resolve the uncertainty?

**No-silent-upgrade rule.** The chain `possible → likely → supported →
demonstrated` may not be traversed without naming the evidence item that
justifies the step. Each rung requires a locator. If you cannot name one, you are
at the lower rung.

### Step 5 — Anti-red-team the objection

Now try to falsify the objection itself. This step is not permission to produce
another round of rhetoric.

**Concrete-answer requirement.** Write the specific thing that would show the
objection wrong: an observation, a source, a calculation, an experiment, or
supplied context. "More scrutiny would help" is not an answer. "Another model
disagreed" is not an answer. "It is theoretically possible" is not an answer.

Then check whether such evidence is present in the boundary.

**If nothing in the boundary can distinguish the objection from its rejection,
classify `unresolved` or `unsupported`.** The existence of a counterargument is
not a resolution. A generated counterargument is not evidence — see § 8.

### Step 6 — Classify

Exactly one primary `status` per objection:

| Status | Meaning |
| --- | --- |
| `supported` | Available evidence meaningfully supports the objection. |
| `contradicted` | Available evidence meaningfully conflicts with the objection. |
| `unsupported` | Plausible, but available evidence does not support it. |
| `unresolved` | Material and relevant evidence exists, but the available information cannot settle it. |
| `not_applicable` | The objection does not apply to this claim or context. |

**Terminology rule.** `unsupported` is not `false`. Insufficient evidence to
establish an objection means `unsupported` — never "this objection is wrong",
unless there is evidence that conflicts with it, which is `contradicted`. Do not
use "rejected" as a synonym for "false".

### Step 7 — Separate risk from demonstrated problem

This is a second, independent axis. For each objection, classify both.

**`evidence_status`** — how well the evidence settles the matter:

- `demonstrated` — the evidence shows the situation actually obtained;
- `supported` — the evidence meaningfully indicates it, with residual doubt;
- `possible` — not excluded, not indicated;
- `unknown` — cannot be assessed from the boundary.

**`problem_status`** — what kind of thing it is:

- `substantive_problem` — it demonstrably affects the claim, its scope, or the
  decision built on it;
- `meaningful_risk` — a real concern that would matter if it obtained, with no
  evidence that it obtained;
- `minor_limitation` — real but not decision-relevant;
- `no_demonstrated_problem` — nothing wrong established.

The canonical distinction:

> "The sample may not represent the target population" is a legitimate
> methodological **risk**. It does not establish "the study has an invalid
> sample". The first is `evidence_status: possible` + `problem_status:
> meaningful_risk`. The second is `evidence_status: demonstrated` +
> `problem_status: substantive_problem`.

The protocol must never let a plausible methodological concern graduate into a
claimed defect through sheer repetition.

### Step 8 — Assess materiality

For each objection, ask whether resolving it could change the truth of the
claim, its scope, the confidence warranted, the decision, or the interpretation.

Classify `material`, `potentially_material`, or `immaterial`.

**Counterfactual requirement.** `material` requires a stated counterfactual: name
what would change if the objection were resolved against the claim. Without a
named consequence, the correct value is `potentially_material` at most.

**No-volume rule.** An objection is not material because it sounds important.
Severity-sounding language is not a materiality argument. Many immaterial
objections do not add up to a material objection; materiality is assessed per
objection against the specific decision, not by counting.

### Step 9 — Determine decision impact

One of `revise`, `investigate`, `retain`, `no_effect`.

- `revise` — the claim, interpretation, or decision should change.
- `investigate` — a specific, nameable evidence-gathering step would settle it.
- `retain` — the objection bears on the claim, but resolving it does not
  warrant changing anything.
- `no_effect` — the objection does not bear on the claim at all.

Note the distinction between `retain` and `no_effect`: `retain` means the
objection was weighed and did not warrant action; `no_effect` means it was
outside the claim's scope or refuted.

**Derivation rule.** `revise` is never automatic on objection existence. It
requires `status: supported` **and** `problem_status: substantive_problem` **and**
`materiality: material`. Any weaker combination yields `investigate`,
`retain`, or `no_effect`.

### Step 10 — Produce the overall result

One of `revise`, `investigate`, `retain`, `uncertain`, `underspecified_claim`.

- `revise` — evidence supports a substantive problem warranting a change.
- `investigate` — a potentially material issue exists; evidence is insufficient
  to resolve it.
- `retain` — no supported substantive problem was identified that warrants
  changing the claim.
- `uncertain` — evidence is too incomplete or conflicting for a reliable
  conclusion.
- `underspecified_claim` — the claim must be clarified before critique.

**The retain rule.** `retain` does **not** mean the claim is validated. It means:

> No supported problem was identified from the available evidence that currently
> warrants revision.

The mandated plain-language statement for a null result is:

> No supported problem identified from the available evidence.

That sentence must never be paraphrased into "the claim is proven", "validated",
"confirmed", or "correct". See `tests/null-result.md`.

---

## 3. Evidence boundary and independence limits

### 3.1 Background knowledge is not evidence

Model knowledge may propose hypotheses. It may not support a finding. This is
not a style preference: without it, every objection the model can imagine becomes
an apparently supported objection, which is precisely the failure this protocol
exists to prevent.

The constraint is asymmetric on purpose. Model knowledge cannot *support* an
objection, because "that is generally true" is not a reason. But supplied
evidence can *refute* one, and doing so is the normal path to a `contradicted`
finding. Refuting an objection with evidence is not the same as supporting it
with knowledge.

### 3.2 LLM passes are not independent evidence

The pipeline

```
generation → verification → anti-red-team
```

is **one model reasoning three times**, not three judgments. Adding passes
increases the amount of generated reasoning; it does not add evidence.

Therefore the following are prohibited as evidence:

- "another model agreed with this objection";
- "the objection survived a critical pass";
- "the model considered and rejected its own objection";
- "no counterargument could be generated" (absence of a generated argument is
  not evidence of absence).

A second model is not an independent ground truth either. It shares training
data, inherits the same framing, and is subject to the same incentive to produce
a plausible-sounding objection. Agreement between correlated judges is not
corroboration.

### 3.3 Self-critique does not escape model bias

An evaluator critiquing its own output tends to reproduce that output's blind
spots, because the blind spots are features of the evaluator, not of the text.
Where the claim under critique was itself generated by an LLM, this is doubly
true: the same systematic errors appear on both sides.

### 3.4 Human adjudication is also fallible

Human reviewers bring confirmation bias, incentives, time pressure, and domain
blind spots. Human adjudication is usually stronger evidence than generated
reasoning, but it is not an oracle, and disagreement between two humans is a
signal about the question's difficulty.

### 3.5 External evidence outranks generated reasoning

An observation with a locator beats an eloquent argument without one. When a
decision turns on whether something is actually the case, prefer the measurement,
the document, or the reproducible calculation — not the additional pass.

---

## 4. Confidence

Confidence describes **confidence in this evaluation** — in the classification,
materiality, and decision impact assigned to each objection. It is *not*
confidence in the original claim. A `retain` result carries no confidence that the
claim is true.

Levels: `low`, `medium`, `high`.

**Constraint.** Confidence is bounded by evidence quality and completeness.

**Protocol violation.** `confidence: high` combined with weak, absent, or
background-only evidence. High confidence requires a non-empty, supplied-evidence
basis and `evidence_status` of `demonstrated` or `supported`. Any other
combination must be downgraded.

Never convert uncertainty into confidence because an explanation can be
articulated. If the explanation is the only thing supporting the rating, the
rating is `low`.

---

## 5. Evaluator error

### 5.1 Definitions

Relative to ground truth for a given objection:

- **True positive (TP)** — the objection is a real problem, and the protocol
  classified it `supported`.
- **False positive (FP)** — the objection is not a real problem, and the
  protocol classified it `supported`. *This is the characteristic failure of a
  red-team evaluator.*
- **True negative (TN)** — the objection is not a real problem, and the protocol
  did not treat it as supported.
- **False negative (FN)** — the objection is a real problem, and the protocol
  missed it, or filed it as `unsupported`, `not_applicable`, or returned
  `retain`.

- **Precision** — TP / (TP + FP). Of the objections the protocol endorsed, how
  many were real.
- **Recall** — TP / (TP + FN). Of the real problems, how many the protocol found.
- **Calibration** — whether stated confidence tracks actual correctness.

### 5.2 Ground truth is required, and is usually absent

TP, FP, TN, and FN are defined **relative to ground truth**. Ground truth may
come from empirical testing, authoritative evidence, reproducible calculation,
expert adjudication, benchmark labels, or subsequent outcomes.

The evaluator's own agreement does not supply ground truth. A model saying "the
objection is correct" does not make a true positive of it. A model returning "no
supported problem" does not make a true negative.

**Where ground truth is unavailable, record exactly:**

```
evaluator_error_rate: evaluator_error_rate_not_determinable
```

Do not invent, estimate, or imply a precision, recall, or error rate. Do not
report a percentage that was not measured against something.

### 5.3 Error is asymmetric in practice

A red-team framing biases toward false positives; a confirmation framing biases
toward false negatives. This protocol addresses the first bias by making null
results reportable and by forbidding evidence-free escalation. It does not
eliminate either bias, and it does not measure them.

---

## 6. Output requirements

Every run must emit the record defined in `schema.md`. Requirements:

1. **One status per objection.** No hedging across two statuses; if the truth is
   that it cannot be settled, that is `unresolved`.
2. **Locators or empty.** `supporting_evidence` and `contradicting_evidence` are
   lists. Empty is a valid, honest value. If you cannot cite, you have not found
   evidence.
3. **Basis is declared.** Every objection states whether it rests on supplied
   evidence or background knowledge.
4. **Confidence is scoped to the evaluation** and constrained per § 4.
5. **Limitations are recorded**, including unavailable evidence and whether
   external research happened.
6. **Overall result is one of the five permitted values**, with a plain-language
   statement that does not overstate it.
7. **Non-independence is disclosed** in every run, per § 3.

### 6.1 Prohibited outputs

- A single "red-team score" as the headline result.
- "Proven", "validated", "confirmed", "verified" applied to a claim that was
  merely not objected to.
- Citations to sources not supplied in the boundary.
- Precision, recall, or error rates without ground truth.
- Confidence in the original claim presented as a by-product of the critique.
- The phrase "no issues found" standing alone, without the evidence boundary it
  was reached within.

---

## 7. Compliance self-check

Before returning a result, confirm:

1. Did I return early with `underspecified_claim` where the claim was materially
   underspecified?
2. Is every `supporting_evidence` and `contradicting_evidence` item traceable to
   the boundary, with none sourced from background knowledge?
3. Did any objection get promoted a rung without a named locator?
4. Does every objection with `status: supported` carry evidence, not just
   plausibility?
5. Is `evidence_status` separated from `problem_status` everywhere?
6. Does every `material` classification have a stated counterfactual?
7. Is any `revise` issued without `supported` + `substantive_problem` +
   `material`?
8. Is any `high` confidence resting on absent or background-only evidence?
9. Is `retain` stated as "no supported problem identified from the available
   evidence", without validation language?
10. Have I disclosed that LLM passes are not independent evidence?
11. Have I recorded `evaluator_error_rate_not_determinable` wherever ground truth
    is absent?
12. Have I avoided template objections that are not tethered to this claim?

Any "no" is a protocol violation to be repaired before output.