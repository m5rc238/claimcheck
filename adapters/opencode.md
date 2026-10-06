# Adapter: OpenCode

OpenCode reads `SKILL.md` from a skill directory and uses its frontmatter
`description` as the activation contract. This adapter covers install and
invocation only; the protocol itself is in `SKILL.md`, which is what OpenCode
loads.

## Install

Skills live in `~/.config/opencode/skills/<name>/`. The directory needs a
`SKILL.md` with `name` and `description` frontmatter.

```bash
# clone straight into the skills directory
git clone <this-repo> ~/.config/opencode/skills/epistemic-redteam

# or symlink a working copy, so edits take effect immediately
ln -s /path/to/claimcheck ~/.config/opencode/skills/epistemic-redteam
```

Verify the file lands where the loader looks:

```bash
ls ~/.config/opencode/skills/epistemic-redteam/SKILL.md
```

## Invoke

Ask in the language of the claim. The `description` frontmatter is written to
trigger on the usual phrasings:

> red-team this claim
> what's wrong with this analysis
> check whether this finding holds up
> audit this critique
> is this claim supported by the evidence

Then supply the claim and the evidence. The evidence boundary is the part that
matters: whatever you paste is what the audit may cite. Files in the workspace
are in scope when you name them.

## No external dependencies

The skill needs nothing installed. No model calls, no network, no runtime. It is
markdown and a frontmatter block.

`SKILL.md` instructs OpenCode to run the protocol; it does not reproduce
`README.md`. The reasoning guidance lives in `SKILL.md`, the normative
specification lives in `protocol.md`, and the field contract lives in
`schema.md`.

## Using the portable prompt instead

If you would rather not install anything, paste `PROMPT.md` into the session as a
message and follow it for the rest of the conversation. Same protocol, no
registration step.

## Running the checks

The repository's own test suite is Ruby with no gems:

```bash
./tests/run.sh
```

## Notes specific to OpenCode

- **Long conversations accumulate bias.** The protocol's disclosure rules matter
  more in a long session, not less: by the twentieth claim, a model has an
  incentive to find a pattern, and "the same objection keeps recurring" will feel
  like evidence. It is not.
- **Workspace files are evidence.** If a file is in the workspace, the model may
  cite it. Have it list `evidence_boundary.available_evidence` explicitly and
  check that list against what you actually supplied. A file that appeared in
  the boundary without being provided is a fabricated source.
- **`grep`/`glob` are available.** Useful for locating a real locator when a
  supplied document needs a precise citation, which raises the quality of the
  audit more than any prompt change.

## Adapting the frontmatter

`description` is what determines whether the skill loads at all. If you fork
this, keep it dense with the phrasings you actually expect to use, and keep it a
list of triggers rather than a description of the protocol — a protocol summary
in the `description` wastes the activation budget.

`name` must match the directory name for the loader to resolve it predictably.