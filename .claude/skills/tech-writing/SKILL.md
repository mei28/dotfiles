---
name: tech-writing
description: English technical prose norms - claims stated at the strength their evidence supports, concrete replacements for hype and vague superlatives, list and heading formatting that does not read as machine-generated, sentence-level clarity rules, and how to revise a document. Use when writing or revising English documentation, READMEs, PR bodies, and release notes, including English versions of Japanese documents, or to diagnose prose that is accurate but reads as generated.
---

# tech-writing

The "Technical Writing Guidelines" in `~/.claude/AGENTS.md` apply to every text, always. This
skill expands them for documentation, READMEs, PR bodies, and release notes; commit messages and
code comments follow AGENTS.md alone. For papers, `../kenq/references/prose.md` takes precedence.
Japanese prose: `../japanese-tech-writing/SKILL.md`.

The goal is a document readers follow on the first pass: decide what they need, connect each
claim to its evidence, and only then polish. Respect the house conventions of the publication and
the scope of the request; treat the examples as models for judging similar passages.

## Claims

Every claim carries its evidence or it does not get made.

- A number appears only with its source stated: a source document, a measurement, a
  configuration, an assumption, or a calculation. A measurement also says what was measured,
  against what, on what. Never present an estimate or a configured limit as a measurement.
- "Best practice", "industry standard", "widely adopted" are claims about the world. Name who
  does it, or drop the framing and state the practice on its own.
- Do not call your own output comprehensive, robust, production-ready, or thorough. The reader
  decides that. When the reader's use of the result depends on it, state what it covers and
  what it does not.
- Do not invent experiences, observations, or verification to make the prose sound natural.

Bad: Reduces manual test writing by up to 97% while improving coverage.
Good: Generates one test per public method. Does not cover error paths or concurrency.

## Superlatives

Replace the word with the fact it stands in for.

- revolutionary / game-changer / paradigm shift → what specifically changes, and from what
- ultimate / powerful / advanced → what it does that the alternative does not
- fast / efficient / significantly → the measurement, with units, baseline, and source
- seamless / effortless / magical → the steps that are no longer required
- completely / all / every → the actual scope ("the three loaders", "most callers")
- leverage / utilize → use
- delve into / dive deep → the verb you mean: read, trace, test, measure

If removing the word loses nothing, the word was decoration. Remove it.

## Lists

- No emoji anywhere. Not as bullets, not as status markers, not in headings.
- Emphasis prefixes such as `**Important**:` and `**Note**:` stay banned. A `**Label**: text`
  bullet is allowed when the label helps readers find or compare items (term definitions, named
  options, settings) and banned when it restates the sentence after it: make that bullet a
  sentence, or promote the label to a heading if it is really a section. Dropping the labels and
  dropping the list are separate decisions.
- Three or fewer short items is usually a sentence. Write the sentence. Independent requests,
  owners, deadlines, or steps that readers scan stay a list.
- Do not number what has no order. Numbers promise sequence.

Bad: `- **Token Cache Mechanism** (src/auth/tokenCache.ts)`, a label the path already says.
Good: `- src/auth/tokenCache.ts caches tokens for the lifetime of the process.`
Good: `- **Replica**: a read-only copy of a shard, kept on another node.` (a term readers look up)

## Sentences

- Active voice, subject first: "The parser rejects empty input". Use the passive when the thing
  acted on, or the procedure, is the topic and who acts is irrelevant, including when that keeps
  known information ahead of new: "Each upload is scanned before it is stored."
- One idea per sentence, where an idea is one claim with its condition, reason, or contrast.
  Split independent claims joined by "and". Do not cut a claim off from its condition: strings of
  disconnected short sentences leave readers to rebuild the relationships.
- Cut the wind-up. "It is important to note that" → nothing. "In order to" → "to".
  "first and foremost" → "first". "be able to" → "can". "make changes to" → "change".
- Prefer the specific verb. "handles" and "manages" hide what the code does.
- Keep terminology fixed: one name per concept, including headings, identifiers, and UI labels.
- Keep the tone consistent across passages with the same role. Conversational tone and
  contractions belong only in personal observations.

## Structure

- Lead with the conclusion. The reader should be able to stop after the first paragraph.
- A heading names its section's content. Conventional role headings ("Introduction",
  "Conclusion", "References") are fine. Generic role names such as "Overview" or "Details" are
  banned where the content can be named: "Rate limiting", not "Overview".
- Do not restate the heading in the first sentence under it.
- Judge a closing summary by what it does. Keep it when it ties examples together, restates the
  main points after a long explanation, or sets up the next topic; cut it when it only repeats
  what the reader just read. When unsure, read the passage with and without it.

## Revising

When revising a document, whether the user's or your own:

1. Infer the reader and purpose and state them in one line at the top of the reply. Ask only when
   they cannot be inferred.
2. Propose structural changes (reordering sections, deleting or merging paragraphs, choosing
   which content stays) before applying them.
3. Apply sentence-level edits directly to the file.
4. Report a ledger: each change with its reason, factual corrections separately, and the claims
   that could not be verified.

Settle accuracy and structure before polishing sentences. There is no fixed number of passes:
stop when no concrete problem remains and no further change can be justified. Full procedure:
`../japanese-tech-writing/references/revision.md` (Japanese, shared by both languages).

## Check before handing it over

1. Grep for emoji (there must be none) and for `- **`. Judge each label hit by `## Lists`.
2. Find every number and factual claim. Name each number's source: document, measurement,
   configuration, assumption, or calculation. A claim you introduced without a source gets
   verified or removed; a claim of the user's that you cannot verify stays and is reported as
   unverified.
3. Delete every adjective in one pass and read it again. Restore only the ones whose absence
   changed the meaning.
4. Read the first sentence of each paragraph in sequence. That chain should be the argument.
5. Find the two or three words you repeated most. If they are vague ("system", "handle",
   "support"), replace each with what it actually refers to. Defined technical terms stay.
6. Remove chat wrappers that leaked in ("Sure, here's the updated README", "Let me know if you'd
   like changes", offers to write more) and stock remarks on a model's knowledge limits. Keep
   true disclosures of tool use.

## Symptoms

Name the defect before editing a passage that "reads as generated": the same explanation twice,
detail readers do not need, interpretation that would fit any subject, a mechanical cadence, or a
claim that outruns its evidence. Fix that defect without giving up correctness, needed
explanation, accessibility, or honest credit. AI-detector scores and word tallies cannot tell you
whether a document explains its subject. Tallies only point at passages to review; sentence
length, openings, punctuation, and pronoun rates have no target values.

- Fluent but says nothing → claims without evidence. Apply `## Claims`.
- Every paragraph the same shape → labels that restate their sentences, or sentence length
  chosen for variety rather than meaning. Apply `## Lists` and `## Sentences`. Do not vary
  sentences only to change the rhythm or to get past a detector.
- Reader asks "compared to what?" → a superlative survived. Apply `## Superlatives`.
- Long and still unclear → wind-up phrases, claims cut off from their conditions, or a passive
  that hides an actor who matters. Apply `## Sentences`.

## When to read the references

| When | Read |
|---|---|
| Results, numbers, comparisons, sources, recommendations, dates, caveats | `references/claims.md` |
| Readers, content selection, order, headings, notes, captions, tables or lists | `references/structure.md` |
| Connections, rhythm, padding, terms, word choice, voice, English notation | `references/sentences.md` |
| A genre pattern, an English version of a Japanese document, prices, affiliate links, collapsible notes, UI labels | `references/genres.md` |
| Revising a document | `../japanese-tech-writing/references/revision.md` |

## Sources

Rewritten from imos's humanizer (<https://imoz.jp/humanizer.en.txt>); section mapping and update
procedure: `../japanese-tech-writing/references/upstream-humanizer.md`.
