---
name: grill-me
description: Interviews you one question at a time, mapping the subject as a decision tree so that no question is asked before its prerequisites are settled. Use when you ask to be grilled or to stress-test a plan, decision, or idea, and before implementing or planning from a requirement vague enough that several materially different designs would satisfy it.
---

# grill-me

Interview until you and the user reach a shared understanding. The result is not a document; it is
a sharper version of the idea. Do not act on it until the user confirms the understanding is shared.

## The decision tree

Model the subject as a decision tree: every decision branches into the decisions that hang off it.

The frontier is every decision whose prerequisites are already settled: the questions that can
honestly be asked now, without guessing at answers you have not heard yet. A question that hinges on
something still open is not on the frontier. Hold it.

Ask one frontier question at a time. Pick the one with the widest blast radius, the answer that
reshapes the most of the tree below it. Wait for the answer, then recompute the frontier before
asking the next one. Do not batch questions, and do not queue up a list.

The frontier is your judgement, not a computed graph. When an answer turns out to invalidate a
question you already asked, say so and reopen that branch.

## Question format

Numbered continuously across the session so the user can refer back. Ask in Japanese.

```
Q1. <short title>

<what is undecided, why it matters, and 2-4 concrete options when they exist>

推奨: <your answer and the one-line reason for it>
```

No emoji, no bold prefixes: `~/.claude/AGENTS.md` の Technical Writing Guidelines に従う。

When your recommendation argues against the question as worded, say so in the recommendation line,
so that "agree with the recommendation" and "yes" do not point in opposite directions.

Two questions never merge into one. Two options never hide inside a single sentence.

## Facts are yours, decisions are theirs

Finding facts is your job, never the user's. When a question needs something the environment can
settle (files, config, git history, library behavior, what a dependency actually does), dispatch the
Explore subagent and find out. Never ask what you could look up.

Do not block on it. A running exploration is an unsettled prerequisite: only the questions
downstream of it wait. Ask another frontier question meanwhile.

Decisions are the user's. Answering your own question breaks this skill, however obvious the answer
looks. "I don't know" is a real answer, and it usually means the question is ungrillable rather than
that you should decide it.

## Ungrillable questions

Some questions cannot be settled by talking: how something should look, how an interaction should
feel, whether one long form beats three pages. They need something to react to. Name the question as
ungrillable, stop grilling that branch, and propose building the throwaway version first.

Talking through an ungrillable question is where sessions balloon: the questions get rephrased, the
answers get guessed, and the scope grows to fill the uncertainty.

## Coverage

When the subject is software, sweep these to find decisions the user has been making implicitly:
module boundaries and where the logic lives, data model and state ownership, API surface and error
contracts, UI flow and failure states, test strategy, authorization and handling of sensitive data,
performance limits, deployment, migration, and rollback.

This is a checklist for finding questions, not a template to fill in. Skip what does not apply.

## Inside plan mode

This skill runs in plan mode as well. Plan mode pushes toward producing a plan, and the interview
comes first: keep asking one question at a time, and do not call `ExitPlanMode` until the frontier is
empty and the user has confirmed. Write the plan file from what the interview settled, not from what
you assumed before it started.

## Ending

The session is done when the frontier is empty: every branch visited, nothing left silently assumed.
Say so, and ask the user to confirm that the understanding is shared. Do not start implementing
until they do.

Long sessions are a scope signal, not a thoroughness signal. When the questions keep multiplying,
say the scope is too large and propose splitting the work into pieces to grill separately.

It is working if the user disagrees with something, if later questions could not have been asked
first, and if the user ends up somewhere they did not expect because a question surfaced a decision
they had been making implicitly.

## Sources

Adapted from mattpocock/skills (MIT), <https://github.com/mattpocock/skills>: the `grilling`
primitive and its `grill-me` front door, merged into one skill. Changes from upstream: sequential
questioning instead of batched rounds, plain-text question format, the Explore subagent named
explicitly, plan mode kept on with an explicit gate, and the category sweep inherited from the
`dig` skill this replaces.
