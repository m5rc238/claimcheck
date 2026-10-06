# Adapter: ChatGPT

ChatGPT has no skill directory. The whole protocol ships in `PROMPT.md`, which
is designed to be pasted and used.

## Setup

Nothing to install.

## Option 1 — paste the prompt (recommended)

1. Open the conversation.
2. Paste the fenced block from `PROMPT.md`.
3. Paste your claim into the marked slot at the end.

The protocol is self-contained. Nothing from this repository needs to be
reachable.

## Option 2 — a project

If you use ChatGPT Projects, drop `PROMPT.md` into the project's instructions and
`examples/` into the knowledge base. The examples matter: the protocol is more
reliably followed when the model has seen a null result and a `retain` statement
that does not drift into validation language, rather than only a worked example
that finds problems.

## Option 3 — a custom GPT

Configure it with the `PROMPT.md` block as instructions. Include `examples/` as
knowledge files.

## What to expect differently from a coding agent

**Uploads are your evidence boundary.** Whatever you attach is what the audit may
cite. Do not let the model fill in "the uploaded report indicates…"; check the
`evidence_boundary` block against what you actually attached. A source that
appears there without being attached is a fabrication, and it is the single
easiest failure to catch by reading.

**No external research unless you enable it.** In a chat without browsing, the
`external_research` value should read `unavailable` or `not_authorized`. If you
want the model to search, say so explicitly and enable browsing, then expect
`authorized` or `attempted`. Do not assume searching happened.

**Sessions are not evidence sources.** A claim discussed earlier in the
conversation is context, not a source. If a finding matters, get it into the
uploaded material.

**Model identity may vary between turns.** If a long audit spans a model change,
the correlated-error analysis gets weaker, not stronger: two different models on
the same framing are still two samples of the same incentive. Record the passes
in `independence.passes_performed` and keep `independent_judgments: false`.

## A prompt worth adding for one-off use

If you only want the anti-inflation behaviour and not the full record, this is the
short version — paste it after your claim:

```text
Before you critique this, tell me what evidence is available to you and what is
not. List candidate objections and label each as a candidate. Then for each one
tell me what evidence supports it, what contradicts it, and whether it actually
applies to this claim or only to claims of this shape. Do not upgrade a
possibility into a finding without naming the evidence for the step. If nothing
survives, say "no supported problem identified from the available evidence" — and
do not describe that as validating the claim.
```

This captures the core discipline in about a fifth of the text. It will not
produce the full record, so drop the materiality and decision-impact steps if you
need brevity — but do not drop the evidence boundary or the null-result rule.

## Reading the output

Check three things, in this order:

1. `evidence_boundary` — is it the material you actually supplied?
2. `supporting_evidence` on anything marked `supported` — is it non-empty?
3. `overall_result.statement` — does it overstate what the result means?

An objection marked `supported` with an empty evidence list is the failure mode
this repository exists to catch, and it is the fastest thing to look for.

## Files

- `PROMPT.md` — the portable prompt
- `examples/` — worked records worth uploading as knowledge
- `schema.md` — if you want the model to emit strict fields
- `adapters/chatgpt.md` — this file