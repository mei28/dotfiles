# Genres, translation, and publication details

Open this file when the document belongs to a recognizable kind (concept explanation, comparison
or estimate, procedure, specification, personal review), when it is the English version of a
Japanese document, or when the page carries prices, affiliate links, collapsible notes, or
translated interface labels.

## Document patterns

Take the starting order that matches the document's purpose, then adapt it to what readers know
and how deep the document goes.

| Purpose | Starting order | Where the weight goes |
|---|---|---|
| Explaining a concept or mechanism | The question and its short answer → a worked case → how it works → what follows, and when it holds | Cases that represent the typical situation, and why the result comes out as it does. An overview can leave detailed derivations to notes. |
| Comparing options or estimating an outcome | The question → key assumptions → method and results → sensitivity to the conditions → conclusion | One set of criteria, units, and conditions for every option. Keep sourced values, assumptions, calculations, and judgments apart, and show which assumptions move the conclusion. |
| Walking through a procedure | What readers will have at the end → what they need first → the steps → how to confirm success → frequent failures | Actions readers can carry out and results they can see. Failures worth covering are the ones that help readers finish. |
| Documenting a specification or method | What it covers and when to use it → definitions → conditions and behavior → examples → limits | Notation, guarantees, and implementation rules placed where readers can find them. Definitions written out formally. |
| Recounting an experience or a decision | Context and goal → what happened or was observed → why the judgment came out as it did → where it applies | Concrete observations in the first person. What the author lived through, what they read up on, and what they recommend stay distinguishable. |

When a section's purpose changes, its order can change too; a concept explanation may contain
implementation steps, for instance.

## Translation and synchronization

For papers, kenq's `../../kenq/references/prose.md` (英語にする段階) takes precedence over this
section.

Each language version is edited for its own audience. What must match across versions: the shared
facts, the technical definitions, where the author stands, and how strongly and under what
conditions each claim is made. Each version must stand on its own in supporting its conclusions.
Outline, examples, and length are free to differ. If a reconstructed English version would explain
the subject better, reconstruct it, choosing the structure for English readers rather than
mirroring the Japanese wherever that helps.

Both versions face the same bar for reading effort and for relevance of detail. How much
background to give depends on what the audience knows and wants, not on which language they read;
the language alone says nothing about expertise or appetite for detail. Material drawn from either
version, and anything newly added, goes through the content-selection test in `structure.md`. New
examples and derivations get the same scrutiny as those carried over.

### Read both versions first

Before drafting, read the source and whatever English version exists, even if you plan to write
the English afresh. Keep two sets of notes:

| Notes | What goes in them |
|---|---|
| Shared content | Everything both versions must agree on: claims with their evidence and limitations, definitions and assumptions, mechanisms, equations and results, examples, attribution. For each requested correction, whether it touches a claim in the English and why. |
| Candidate explanations | Ways of opening, examples, wording, comparisons, and interpretations that might work well for English readers. |

Track corrections of fact apart from adjustments made for an audience. A correction must reach
every place in the English it affects, fluent passages included, when they still rely on a
superseded definition or an example the correction knocked out. When the versions conflict on
substance and the requested change leaves the conflict standing, go back to the derivation, the
implementation, or the source.

### Rebuild the explanation in English

Plan the English around three units of meaning: the problem, the choices made and why, and the
results with what they mean. Work from those units, not from a sentence-by-sentence mapping of
Japanese onto English paragraphs.

- When two short source sentences relate more clearly as one sentence with a subordinate clause,
  merge them; break up a dense sentence that bundles separate steps or claims.
- Japanese often omits subjects and logical connectives. Add them where the context makes them
  unambiguous, and resolve any doubt before deciding who acted, what caused what, or how far a
  statement reaches.
- Move or regroup sections so that each step of the argument comes after the steps it depends on.
  The two versions may run in different directions: one builds a method up from a use case, the
  other states the result first and derives it afterward.
- Use a different example if it makes the mechanism clearer. Add the prerequisites English readers
  are missing and shorten background they already have, without dropping the support and
  qualifications any conclusion needs.
- The author's decisions, mathematical consequences, observations, and predictions rest on
  different kinds of support; smooth English must keep them distinguishable.

When the structure changes, renumber figures and fix cross-references. Revisit note placement as
well: a definition tucked into a Japanese note may need to move into the English body, and a short
English clause may do the work of a full Japanese sentence.

### Review meaning and English

First confirm that every shared claim carries the relevant corrections without losing conditions or
strength, and that the shared claims agree between versions. Then read the English as a standalone
document without glancing at the source, and sketch how it opens, what it compares, and how it
concludes. For each part, ask what it helps readers grasp and whether readers can see what connects
to what and what each reference points to; check that the document backs up its answers. Mend
breaks in the flow and missing links; where one outline works for both audiences, keep it. Look
again at additions that fill no gap and at cuts that open one. Run these checks as part of the
revision procedure (SKILL.md `## Revising`).

## Personal reviews

A personal review is worth reading for its concrete experience and frank judgment, so keep both.
"I used", "I researched", and "I would choose" report different things: picking a product for its
features is not the same as having used it. "I ran it on my laptop for two weeks" and "From the
spec sheet, I would pick the 32 GB model" rest on different kinds of support. Never fabricate
experiences, feelings, stories of discovery, or testing to make a review feel more personal.

## Prices, selection criteria, and affiliate links

Where the evidence supports only a range or an estimate, give the price that way, dated as
described in `claims.md`. Tell readers how items were chosen before listing or comparing them.
Cover the differences and downsides that matter for the intended use, and mark which statements
are sourced facts and which are ratings or recommendations. If the page has affiliate links, say so
plainly near the top, before the first link appears.

## Collapsible notes

Footnotes, appendices, and collapsible notes are all options; use what the publication supports.
Most readers never open a collapsible note, so each visible claim must be correct with every note
closed, and the page is reviewed in that state. A collapsible note's summary line is its entry
point (`structure.md`) and should say what opening it will add.

## Interface labels and other translated text

Translation covers more than the body: chart labels, legends, alt text, table headings, and
interactive controls too. Leave terms and identifiers that already work in English. Make sure
translated labels fit their space and leave the data and meaning unchanged.
