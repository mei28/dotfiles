---
name: tech-writing
description: English technical prose norms - concrete replacements for hype and vague superlatives, list formatting that does not read as machine-generated, and sentence-level clarity rules. Use when writing or revising English documentation, READMEs, PR bodies, and release notes, or to diagnose prose that is accurate but reads as generated.
---

# tech-writing

The "Technical Writing Guidelines" in `~/.claude/AGENTS.md` apply to every text, always. This is
the expanded version: the patterns behind those rules, worked replacements, and a check to run
before handing the text over. Japanese prose: `../japanese-tech-writing/SKILL.md`.

## Claims

Every claim carries its evidence or it does not get made.

- A number needs a source and a method. "40% faster" means nothing without what was measured,
  against what, on what. If you did not measure it, do not print a number.
- "Best practice", "industry standard", "widely adopted" are claims about the world. Name who
  does it, or drop the framing and state the practice on its own.
- Do not call your own output comprehensive, robust, production-ready, or thorough. The reader
  decides that. State what it covers and what it does not.

Bad: Reduces manual test writing by up to 97% while improving coverage.
Good: Generates one test per public method. Does not cover error paths or concurrency.

## Superlatives

Replace the word with the fact it stands in for.

- revolutionary / game-changer / paradigm shift → what specifically changes, and from what
- ultimate / powerful / advanced → what it does that the alternative does not
- fast / efficient / significantly → the measurement, with units and baseline
- seamless / effortless / magical → the steps that are no longer required
- completely / all / every → the actual scope ("the three loaders", "most callers")
- leverage / utilize → use
- delve into / dive deep → the verb you mean: read, trace, test, measure

If removing the word loses nothing, the word was decoration. Remove it.

## Lists

- No emoji anywhere. Not as bullets, not as status markers, not in headings.
- No `**Label**: text` bullets. That shape reads as generated and it buries the sentence's verb.
  Make the bullet a sentence, or promote the label to a heading if it is really a section.
- Three or fewer short items is usually a sentence. Write the sentence.
- Do not number what has no order. Numbers promise sequence.

Bad:
- **Token Cache Mechanism** (`src/auth/tokenCache.ts`)
- **Authentication API** (`src/api/auth.ts`)

Good:
- `src/auth/tokenCache.ts` caches tokens for the lifetime of the process.
- `src/api/auth.ts` reads from that cache instead of re-authenticating per request.

## Sentences

- Active voice, subject first. "The parser rejects empty input", not "empty input is rejected".
- One idea per sentence. Two ideas joined by "and" are usually two sentences.
- Cut the wind-up. "It is important to note that" → nothing. "In order to" → "to".
  "first and foremost" → "first". "be able to" → "can". "make changes to" → "change".
- Prefer the specific verb. "handles" and "manages" hide what the code does.
- Keep terminology fixed. One name per concept across the whole document, including headings,
  code identifiers, and UI labels.

## Structure

- Lead with the conclusion. The reader should be able to stop after the first paragraph.
- A heading names its section's content, not its rhetorical role. "Rate limiting", not "Overview".
- Do not restate the heading in the first sentence under it.
- Cut the closing summary that repeats what the reader just read.

## Check before handing it over

Run these on the finished text.

1. Grep for emoji and for `- **`. Both should return nothing.
2. Find every number. For each, name where it came from. Delete the ones you cannot source.
3. Delete every adjective in one pass and read it again. Restore only the ones whose absence
   changed the meaning.
4. Read the first sentence of each paragraph in sequence. That chain should be the argument.
5. Find the two or three words you repeated most. If they are vague ("system", "handle",
   "support"), replace each with what it actually refers to.

## Symptoms

- Fluent but says nothing → claims without evidence. Apply `## Claims`.
- Every paragraph the same shape → `**Label**:` lists or uniform sentence length. Apply `## Lists`.
- Reader asks "compared to what?" → a superlative survived. Apply `## Superlatives`.
- Long and still unclear → wind-up phrases and passive voice. Apply `## Sentences`.
