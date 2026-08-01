---
name: tidy-first
description: Kent Beck's Tidy First discipline for changing the structure of existing code - the catalog of named tidyings, when to tidy (first, after, later, never), batch size, and keeping structural changes out of behavioral commits. Use when refactoring, cleaning up before or after a feature, or splitting a diff that mixes restructuring with behavior change.
---

# tidy-first

Structural changes and behavioral changes are different work. Keep them in different commits.
Test-driving new behavior: `../tdd/SKILL.md`. Commit prefixes: `../commit/SKILL.md`.

## Structure and behavior

Software creates value in two ways: what it does today, and what we can make it do tomorrow. Behavior is the first, structure is the second.

- **Structural change**: rearranging code without changing what it does. Rename, extract, move, reorder, split.
- **Behavioral change**: adding or changing what the code does.

Check that a structural change really is structural: run the tests before and after and get the same result. If the result differs, it was a behavioral change wearing a structural name. This is evidence, not proof, and it only covers the paths the tests execute.

## When to tidy

Beck gives four answers, not one.

- **First**: the tidying makes the behavior change you are about to make easier to understand or cheaper to write, and it pays off immediately. Keep it small.
- **After**: the tidying is worth doing and doing it now, while the code is fresh, costs less than coming back later.
- **Later**: a larger batch whose payoff arrives eventually. Schedule it and do it incrementally, never as one big change.
- **Never**: code you will not touch again, or from which you would learn nothing. Untidy is not by itself a reason to tidy.

Not tidying is a legitimate answer. Ask what the tidying buys before starting it.

## The tidyings

Beck's catalog. Use these names when proposing or describing a structural change, so the change is specific rather than "clean this up".

- **Guard Clause**: return early on the precondition so the body is not nested.
- **Dead Code**: delete unused code. Version control keeps the history.
- **Normalize Symmetries**: express the same logic the same way everywhere it appears.
- **New Interface, Old Implementation**: write the interface you wish existed and have it call through to the awkward one.
- **Reading Order**: reorder elements in the order a reader wants them, not the order they were written.
- **Cohesion Order**: put coupled elements next to each other, so a change touches one region.
- **Move Declaration and Initialization Together**: declare a variable where it gets its value.
- **Explaining Variables**: extract a subexpression into a variable named for its intent.
- **Explaining Constants**: replace a literal with a named constant.
- **Explicit Parameters**: split a bag of options into named parameters.
- **Chunk Statements**: put a blank line between distinct logical sections. Often the step that reveals where Extract Helper should cut.
- **Extract Helper**: move a coherent block with a narrow interface into its own function.
- **One Pile**: inline scattered fragments back into one piece so it can be re-split along better lines.
- **Explaining Comments**: record what was not obvious, including defects you noticed.
- **Delete Redundant Comments**: remove comments that only restate the code.

## Batch size and rhythm

Tidying before a behavior change should take minutes to an hour. Longer than that means you have lost sight of the minimum structural change the behavior change actually needs.

Large batches delay integration, raise the chance of collision with others' work, and raise the odds of changing behavior by accident. Prefer many small tidyings over one large one.

Tidying chains: one tidying reveals the next. That is the mechanism by which an hour becomes a day. Stop when the structure you needed is there, and put the rest on a list.

## Commits

- No commit contains both a structural and a behavioral change. If the diff would need two prefixes, split it.
- When both are needed, the structural commit goes first, with the suite green before and after it.
- As few tidyings per commit as possible. They review differently from behavior and should be trivially verifiable.
- Commit only when the whole suite passes, linter and type warnings are resolved, and the change is one logical unit.

Prefix mapping (details in `../commit/SKILL.md`): behavioral is `feat`, `fix`, `perf`; structural is `refactor`; `style` is formatting only, so renames and extractions are `refactor`; tests alone are `test`.

Default to one commit per completed behavior or phase, and rebase later if the history needs splitting. The non-mixing rule holds regardless of granularity.

## Getting untangled

When structure and behavior are already mixed in the working copy, Beck gives three options:

1. Ship it as is, if it is small enough to review honestly.
2. Separate it into distinct commits by hand, which is tedious but preserves the work.
3. Discard it and redo it with the tidying sequenced first.

Pick one and say which. Do not let a tangled diff grow while deciding.

## Mistakes

- Tidying further than necessary. It feels productive and is often avoidance of the harder behavior change.
- Abstracting too soon. Duplication is a hint, not a command.
- Calling a change structural without running the tests before and after.
- Tidying code that the tests you just ran do not execute. Green says nothing about untouched paths.
- Restructuring while a test is red. Get to green first.
- Bundling "while I was in there" cleanups into a feature commit.
- Renaming or moving so broadly that the diff is unreviewable, when a narrower change would have served the behavior change.

## Related skills

- `refactor` finds candidates by static analysis and produces a report. This skill is the discipline for how and when to apply them.
- `../tdd/SKILL.md` step 4 ("optionally refactor") is where this skill enters a red-green cycle.

## Sources

- Kent Beck, *Tidy First?* (the tidyings, first/after/later/never, batch size, rhythm, getting untangled, structure and behavior)
- Kent Beck, BPlusTree3 `rust/docs/CLAUDE.md` (never mix the two, structural first, validate by running tests before and after, commit gate)
