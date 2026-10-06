# epistemic-redteam

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./SKILL.md)
[![tests](https://img.shields.io/badge/tests-8%20cases%20%2B%202%20suites-informational.svg)](./tests/run.sh)

An open-source, model-agnostic protocol for **auditing claims and the critiques
made of them**. Use it in OpenCode, ChatGPT, Claude, or anything else that reads
a prompt.

The objective is not to make a model more skeptical. It is to make the gap
between *what the evidence shows* and *what the model asserts* visible and
auditable.

## Problem

Ask an AI to "red-team this" or "find weaknesses in this claim," and you will get
objections. You will get them whether or not the evidence supports them. The
instruction creates an incentive to produce problems, and a model that produces
problems fluently is indistinguishable from a model that finds them.

Three things go wrong at once:

**1. Plausible objections get promoted to demonstrated problems.** "The sample may
not represent the target population" is a real methodological concern. It is not
a finding that the study has an invalid sample. Without a mechanism to keep those
apart, the concern arrives at the reader as a defect.

**2. The critic can be wrong, and nobody checks.** A critique is itself a claim.
It asserts that something is wrong with something else. It gets no more credit
for being well-formed than the original claim did.

**3. Extra passes look like extra evidence.** Generation → verification →
anti-red-team sounds like three independent judgments. It is one model reasoning
three times. Counting it as corroboration is how a system manufactures its own
confidence.

The result is a red-team step that reliably produces output and has no reliable
way to say *nothing is wrong here*.

## Key idea

> **A critique is itself a claim, and must be auditable like one.**

So audit it with the same discipline. Every objection gets a status, a body of
evidence with locators, a materiality assessment, and a decision impact —
including the statuses that mean "this objection is not supported," and the
overall result that means "no supported problem identified."

## Workflow

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

The load-bearing steps:

| Step | What it prevents |
| --- | --- |
| Formalize the claim | Elaborate objections to an undefined target |
| Set the evidence boundary | Background knowledge silently becoming evidence |
| Generate candidates, labelled as candidates | Rhetoric arriving as findings |
| Test against evidence | Plausibility being read as support |
| Anti-red-team concretely | A counterargument counting as a resolution |
| One status per objection | Hedged, unauditable conclusions |
| Risk vs demonstrated problem | Concerns hardening into defects |
| Materiality with a counterfactual | Loudness standing in for importance |
| Decision impact by derivation | Automatic revision |
| Overall result, nulls allowed | The pressure to always find something |

## Seven outputs, all of them valid

The protocol must be able to produce any of these. A system that can only produce
the first three is a skeptic, not an auditor:

- a supported problem
- a contradicted objection
- an unsupported objection
- an unresolved issue
- an underspecified claim
- a meaningful risk that is not yet demonstrated
- **no supported problem identified**

## Why null results matter

A red-team system that cannot report "nothing found" is not being rigorous. It is
being compelled.

Consider the two failure directions. A system that always finds a problem pays
for a null result in false positives: real objections to sound claims, each
consuming review time and eroding trust in the process. A system that never finds
one pays in false negatives: real problems that ship. Both are bad, and they are
not symmetric in how they are *detected* — a fabricated defect is immediately
visible to a reviewer, while a missed one is invisible by construction.

So the protocol makes the null result a first-class, well-specified answer:

> No supported problem identified from the available evidence.

Three words carry the weight: **from the available evidence**. The finding is
about the audit, not the claim. It expires when the evidence boundary changes.
And it must never be paraphrased into "the claim is validated" — because the
protocol did not validate anything. It ran a procedure, within a boundary, and
the procedure surfaced nothing.

`schema.md` rule R12 enforces this lexically in the test suite, because the drift
from "no supported problem identified" to "validated" happens in exactly one
place: the summary sentence.

## Confidence means confidence in the audit

Not confidence in the claim. A `retain` result carries **zero** information about
whether the claim is true — only about whether this audit found something.

Confidence is bounded by evidence quality and completeness. High confidence
resting on absent or background-only evidence is a protocol violation, not a
strong finding.

## The vocabulary

Exact definitions in `protocol.md` § 1. The distinctions that matter most:

**`unsupported` is not `false`.** Insufficient evidence means unsupported.
Disproof requires conflicting evidence, which is `contradicted`. "Rejected" is
never used as a synonym for "false."

**A risk is not a defect.** Two independent axes, never collapsed:

| | evidence status | problem status |
| --- | --- | --- |
| "The sample may not represent the population" | `possible` | `meaningful_risk` |
| "The study has an invalid sample" | `demonstrated` | `substantive_problem` |

**No issue found is not claim validated.** See above.

**`unresolved` is not "probably fine".** It marks a material question the
evidence cannot settle — the most honest and most frequently skipped answer.

## Examples

Worked records, each one exercising a different path:

| File | What it shows |
| --- | --- |
| [`examples/research-claim.md`](examples/research-claim.md) | A methodological risk that is *not* promoted to a defect |
| [`examples/product-decision.md`](examples/product-decision.md) | A demonstrated problem driving `revise` |
| [`examples/ai-output.md`](examples/ai-output.md) | Auditing a critique that was itself LLM-generated |
| [`examples/underspecified-claim.md`](examples/underspecified-claim.md) | Early exit instead of elaborate objections to an undefined target |
| [`examples/null-result.md`](examples/null-result.md) | `retain`, stated so it cannot be read as validation |

A taste of the difference, from `examples/research-claim.md` — the same concern,
classified two ways:

```yaml
# A risk that survives the audit as a risk:
objection: "Sample was not drawn from the full claims population."
basis: supplied_evidence
status: supported
evidence_status: supported
problem_status: meaningful_risk
materiality: potentially_material
decision_impact: investigate
```

```yaml
# A defect, which this evidence does NOT support:
objection: "The study's sample is invalid, so its results do not generalize."
status: contradicted          # the report documents the sampling frame
problem_status: no_demonstrated_problem
decision_impact: no_effect
```

Same worry, two different evidentiary situations. The protocol distinguishes them
by pointing at evidence, not at severity.

## Limitations

Read this section before relying on any output.

**The evaluator is also fallible.** Relative to ground truth, this protocol can
produce true positives, false positives, true negatives, and false negatives. The
FP is the characteristic failure of a red-team evaluator. But TP/FP/TN/FN all
require ground truth — empirical testing, authoritative evidence, reproducible
calculation, expert adjudication, benchmark labels, or subsequent outcomes. The
evaluator's own agreement does not supply ground truth, and a null result is not a
true negative unless something external says so. Where ground truth is absent,
the protocol reports `evaluator_error_rate_not_determinable`. It does not
estimate, imply, or invent a rate.

**Passes are correlated.** Generation → verification → anti-red-team is one model
reasoning three times. Errors are correlated because the model is the same. A
second model is not an independent oracle: it shares training data and inherits
the same incentive to sound plausible. Agreement between correlated judges is not
corroboration.

**Self-critique inherits bias.** A model critiquing its own output reproduces
that output's blind spots, because the blind spots belong to the model rather than
to the text.

**Reasoning can be confabulated.** The protocol can generate a fluent, internally
consistent rationale for a conclusion no evidence supports. Plausibility of
explanation is not corroboration — which is why evidence carries locators and
explanations do not.

**Evidence boundaries are incomplete.** The protocol is only as good as what was
supplied. Real problems outside the boundary are invisible to it, and `retain`
means "not in this boundary," not "not present."

**Humans are fallible too.** Reviewers bring confirmation bias, incentives, time
pressure, and domain blind spots. Human adjudication usually beats generated
reasoning; it is not an oracle.

**Passing tests is not reliability.** The eight cases in `tests/` are hand-built
examples checked for internal consistency by `tests/check-consistency.rb`. A
second suite, `tests/mutation-test.rb`, injects one violation of each documented
rule and confirms the checker reports it — so the checks are load-bearing rather
than merely present. Together they demonstrate that the protocol's rules can be
applied coherently to these inputs, and that the checker notices when they are
not. They do not estimate precision, recall, or calibration, and a model that
passes them has not thereby been shown to be accurate.

**No literature is cited here.** Nothing in this repository has been verified
against published work, so nothing is attributed to any. For established concepts
see the established terms in `protocol.md` § 1.1: LLM-as-a-judge, evaluator
reliability, evaluator bias, false positives, false negatives, calibration,
judge instability, imperfect evaluation. The phrase "false skepticism" is this
project's own vocabulary, defined in `protocol.md` § 1.1 — not a term borrowed
from the literature.

## What this is not

Not a way to make AI reliable. Not a scoring system. Not a framework. No
dependencies, no runtime, no model calls.

It improves auditability and calibration. A record produced by this protocol can
be checked by a human, disagreed with on the merits, and its reasoning
reproduced. That is a smaller claim than "this critique is correct," and it is
the claim the project can actually support.

## Install

Copy `PROMPT.md` into any LLM — that is the whole install. No tooling required.

For OpenCode:

```bash
git clone <this-repo> ~/.config/opencode/skills/epistemic-redteam
```

Then the skill is discoverable as `epistemic-redteam`. See
[`adapters/opencode.md`](adapters/opencode.md).

## Layout

```
.
├── README.md          # this file
├── LICENSE            # MIT
├── protocol.md        # normative specification — wins any disagreement
├── schema.md          # field definitions + consistency rules R1–R13
├── SKILL.md           # OpenCode skill
├── PROMPT.md          # portable, standalone, no tooling
├── examples/          # five worked records
│   ├── research-claim.md
│   ├── product-decision.md
│   ├── ai-output.md
│   ├── underspecified-claim.md
│   └── null-result.md
├── adapters/
│   ├── opencode.md
│   ├── chatgpt.md
│   └── claude.md
└── tests/
    ├── check-consistency.rb   # zero-dependency rule checker
    ├── mutation-test.rb       # proves the rule checks are load-bearing
    ├── run.sh                 # entry point (runs both suites)
    ├── false-positive.md
    ├── false-negative.md
    ├── null-result.md
    ├── unsupported-objection.md
    ├── contradicted-objection.md
    ├── unresolved.md
    ├── underspecified.md
    └── risk-vs-problem.md
```

## Tests

```bash
./tests/run.sh
```

Two suites, no network, no dependencies — Ruby's standard library only.

**1. Schema coherence** (`tests/check-consistency.rb`) validates every embedded
critique record in `examples/` and `tests/`: permitted values, required fields,
the status ↔ evidence-status matrix, background knowledge excluded from the
supporting column, `revise` requiring the full chain, confidence bounded by
evidence, the null-result language rule, and — for the eight cases in `tests/` —
agreement between each record and the classifications its `## Expected` section
documents.

**2. Mutation test** (`tests/mutation-test.rb`) takes the shipped records,
injects one violation of each documented rule in turn, and confirms the checker
reports an error naming that rule. A checker that passes everything is
indistinguishable from a checker that checks nothing; this suite is what makes
the first suite mean something.

Both suites verify **internal consistency of the records and of the checker
itself** — not the correctness of any judgment. Neither can tell you whether an
objection should have been `supported`. They can tell you that a record claiming
`supported` with no evidence is incoherent, and that a rule which stopped firing
would be noticed.

## Related work, for orientation

The concepts this protocol operates in are established: LLM-as-a-judge, evaluator
reliability and bias, false positives and false negatives, calibration, judge
instability, imperfect evaluation. This project does not claim novelty in any of
them, and cites no specific papers. If you need the literature, search those
terms; they are the right search terms.

## License

MIT. See [LICENSE](./LICENSE).