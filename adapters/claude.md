# Adapter: Claude

Claude has no skill directory in the plain chat product. As with the ChatGPT
adapter, the protocol travels as text.

## Setup

Nothing to install.

## Option 1 — a project

Claude Projects accept custom instructions plus knowledge files.

1. Create a project.
2. Set the `PROMPT.md` fenced block as custom instructions.
3. Upload `examples/` as knowledge files.

The examples are the part that changes behaviour. A model shown one worked audit
that produced `retain`, and one that produced `revise`, calibrates noticeably
better than a model shown only criticism. If you upload one thing, upload
`examples/null-result.md`.

## Option 2 — paste per conversation

Paste the block from `PROMPT.md`, then your claim. Nothing persists between
conversations, so the prompt must be self-contained — it is.

## Option 3 — an MCP server or tool

If you have your own deployment, `SKILL.md` is the closest analogue to a system
prompt: it carries the priority rules and the execution procedure without the
install framing. `PROMPT.md` is the better text for a user-facing system prompt,
because it is written to be usable by someone who does not know this
repository.

## Using the skills format

If your setup reads `SKILL.md` files, point it at this repository's `SKILL.md`.
The frontmatter (`name`, `description`, `license`, `version`) is standard and
the body is plain markdown with no repository-specific tooling. No dependencies,
no scripts to run.

## Using tools changes the evidence boundary

Claude with tool access can read files, search, and sometimes fetch URLs. This
widens the boundary, which is useful and dangerous in the same move.

- Decide before the audit whether external sources are permitted, and say so in
  the prompt. Then verify `external_research` in the output matches.
- If browsing is enabled, expect `authorized` or `attempted`. If it reads
  `unavailable` while browsing was on, the model did not search — and any claim
  about the wider world in the result is unsupported.
- Treat a tool-produced URL as a source only if it appears in
  `evidence_boundary.available_evidence` with a locator. A quoted passage with no
  locator is not a citation.

## Project-level instruction files

If you keep a repository-level instruction file, the compact form below gives an
agent the anti-inflation behaviour without the full protocol. It is a
supplement, not a replacement.

```text
When auditing a claim or a critique:

- Declare the evidence boundary before generating objections. Separate what was
  supplied from your own background knowledge.
- Label objections as candidates. A plausible objection is not a demonstrated
  problem.
- Never cite background knowledge as supporting evidence for an objection. It may
  still be cited as having generated the objection; supplied evidence may then
  refute it, which is how it becomes "contradicted".
- Do not move from possible to likely to supported to demonstrated without
  naming the evidence for the step.
- Separate risk from defect: report evidence status and problem status
  independently.
- To call something material, state the counterfactual - what would change if it
  were resolved against the claim.
- "Revise" requires supported + substantive problem + material. Nothing weaker.
- If nothing survives, say "No supported problem identified from the available
  evidence." Never phrase that as validating the claim.
- Disclose that model passes are not independent evidence.
- Without ground truth, report evaluator_error_rate_not_determinable.
```

## Reading the output

Same three checks as the ChatGPT adapter: the evidence boundary, the supporting
evidence behind every `supported`, and whether the overall statement overstates.

One Claude-specific note: Claude tends to produce well-organised, balanced-
sounding output, including for unsupported objections. The structure is not
evidence. Read `supporting_evidence` rather than the prose summary.

## Files

- `PROMPT.md` — the portable prompt
- `SKILL.md` — the skills-format version
- `examples/` — worked records
- `schema.md` — for strict field emission
- `adapters/claude.md` — this file