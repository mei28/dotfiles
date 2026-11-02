# Readers, content, and structure

Open this file when deciding who a document serves, what it contains, the order of its parts, and
where each part lives: body, note, caption, table, list, or paragraph.

## Readers and purpose

Start by pinning down the readers: what they know already, and what the document should equip them
to explain, do, or decide by the end. A topic is not enough; state the relationship they should
come to see or the judgment they should be ready to make. "Covers connection pooling" is a topic;
"lets a backend developer decide whether the service needs a pooler in front of Postgres" is a
goal. That goal drives the opening, the depth, and the material. An overview lays out the main
points and how they connect within the requested scope; a tutorial leaves readers able to carry
out the task.

Settle which background you will take for granted and which you will explain. Expertise does not
transfer between fields: someone who runs Linux servers every day may know nothing about signal
processing or contract law.

On a substantial piece, jot down a working brief: the main question readers bring, the answer the
evidence backs, the background assumed, and the evidence still lacking. If the document has more
than one purpose, let one of them dictate reading order. Secondary material (side comparisons,
surveys, reference tables) goes where readers can reach it without derailing an explanation or a
procedure. Neither the brief nor any other editorial note goes into the published text or its HTML
comments. Say who the document is for only if that helps readers judge what it covers.

Center the document on one question and its answer. The body unpacks what the title and summary
promise and how far that promise extends, sets out the main grounds for the answer, and names the
assumptions on which the conclusion rests. Count the cost in reading time and in concepts
introduced, on top of sentence-level clarity.

## Requirements, defaults, and document choices

| Level | Status | Applies to |
|---|---|---|
| Requirement | Never waived. | Factual and logical correctness; evidence; the conditions a claim needs; accurate attribution; technical terms whose meaning matches across language versions |
| Default | Followed unless an established convention or the readers' needs argue otherwise. | Spelling, voice, terminology, notation, presentation |
| Document choice | Made for the reader's goal, and applied alike to sections that play the same role. | Structure, headings, depth, examples, tone |

Alternatives being compared get matching headings, terms, units, assumptions, and criteria.
Sections that do different jobs, say a derivation next to a procedure, may look different. Sentence
length, examples, and where equations sit follow from what is being explained.

A small edit respects the existing conventions as long as they hang together. A substantial
revision reopens structure, tone, and headings as a set. Any break from a default must serve
readers and must meet the same bar for accuracy and evidence.

## Content selection

Weigh each candidate topic as a bundle with everything it brings along: the definitions, examples,
and comparisons it requires, plus its qualifications and cross-references. Imagine the bundle gone
and ask what the target reader would miss: part of the answer or its grounds, a condition for
judging how far the answer reaches, or what they would need to apply or check it. If the answer is
nothing, at the intended depth, cut the bundle.

None of these is a reason on its own to keep a topic: it belongs to the field, it is true, or it
comes up again later. The test applies equally to material already in the draft and to material
you are adding. Never insert examples or later mentions merely so that introducing a concept looks
justified. A README section on the history of a configuration format, with its own glossary, can
be accurate and still give someone installing the tool nothing.

Where kept material belongs is decided in `## Main text, notes, and captions`. Before writing an
added explanation, see what the surrounding text already covers, supply only what is still
missing, and count any extra terms, background, or calculations the addition itself would require.

## Organizing around the reader's next question

Begin with whatever prompted the document: a problem, an observation, a task. Give the main result
soon enough that readers know where they are headed, then lay out the reasoning in the sequence
they need. Define terms as they start to matter. Leading with a concrete case can reduce how much
background a method needs. Anecdotes and rhetorical questions are welcome only when they make the
subject clearer; withholding the answer to build suspense is not.

Match the level of detail to what readers know at each point. The opening carries just the
distinctions needed to grasp the question and the main answer; finer classifications, breakdowns,
and conditions wait for the passage that uses them. Something the document needs eventually does
not have to be front-loaded.

If an opening merely promises activities, such as "introduce the design, walk through the
internals, and discuss trade-offs", replace the promise with the finding the evidence supports and
the reason it matters. Carry along the conditions that limit it: what held on one cluster is not a
general guarantee. Notes about scope or method go before a list's lead-in sentence, so the items
come right after it.

A new method or tool needs its problem stated. When earlier approaches are the reason for it, show
where it departs from them and what that departure changes in practice: "Deduplicating at ingest
means each query scans only one copy of every event" ties a mechanism to its payoff. Once readers
know why the method exists, carry on with how it works without repeating the payoff at every step.

Before reporting a survey, measurement, comparison, or estimate, let the surrounding text show what
it is meant to settle. Doing the work gives readers no reason by itself to care about it. If
the purpose is not obvious, link the work to the question it settles; if readers already know the
purpose, do not say it again.

Each paragraph has one job. Open it from ground readers already stand on and move to the new point;
a claim, then how it works, then what follows, is one shape that works well. A comparison or a
chain of cause and effect stays in one piece when splitting it would leave readers to put the link
back together. A worked example can make an earlier claim concrete; a synthesis can show how
earlier results connect. Fit order and depth to the reader's goal, spending words where a
relationship is hard and saving them where readers already follow. Passages that differ in role or
weight need not match in sentence count or shape. In comparisons and procedures, give
corresponding items the same treatment so readers can locate what they are looking for.

## Repetition, recaps, and section endings

Judge repetition by what each passage is for, not only by its words. Roughly, the opening answers,
the body gives the grounds, and the conclusion tells readers what they can now understand or
decide. Fold together or delete passages that explain the same thing again without a new job. A
conclusion may repeat the central finding; it does not have to recap each section or sit under a
heading of its own.

After a run of examples or a long stretch of explanation, ask whether readers can gather the main
findings and move on to what comes next. If they would have to work out for themselves how the
pieces bear on the main question, add a brief summary of the findings that matter. If the
conclusion shifts into reflection or advice, show how it grows out of what came before. Size the
recap to the length and difficulty of the explanation and to how far the topic moves.

To edit a summary sentence, first ask what it lets readers do right there. If it merely restates
the previous explanation for the same purpose, cut it or merge it. It stays when it ties several
examples together, brings back the key points after a long explanation, or opens the way to the
next topic, repetition notwithstanding. Try the passage both ways and see which one readers follow
more easily without losing the point or its conditions.

| Verdict | Passage | Reason |
|---|---|---|
| Remove | "Builds run on every push to `main`. In other words, each push to `main` starts a build." | The second sentence says the first again. |
| Keep | "Nightly builds run the full suite, while push builds run unit tests only. A failure that only integration tests catch therefore shows up the next morning, not at push time." | The second sentence tells readers what the difference costs them. |
| Recap | After three migration walkthroughs: "In all three migrations, the backfill was the risky step, not the schema change." Then the section moves to scheduling advice. | Each point appeared already; collecting them links the walkthroughs to the advice that follows. |

A concept that recurs is explained where readers first need it; later mentions extend it, or
refresh just enough for the current passage. Reference material may add a brief reminder for
readers who arrive mid-document. After an example, keep the interpretation that answers the
reader's question, and delete a stock closing line such as "The right choice therefore depends on
your specific needs" when the text above has already spelled out those needs and how they matter.

Keep a comparison wherever it shapes the explanation or the decision. Recurring asides like "the
other tool does this too (see the comparison)" can go once the comparison section handles them.
Cross-references send readers to evidence, definitions, or procedures they need, with a reason to
follow the link. The comparison section itself explains which differences decide the choice.

Place checks at the point of use. Inside a procedure, a checklist may repeat facts to head off
mistakes; the surrounding introduction and conclusion need not list them yet again. A
troubleshooting table separates failures someone actually saw from failures inferred from the
specification, and an inferred failure is confirmed before it is described as expected behavior.

Point readers to what a table reveals instead of reading out its column headers. "The table lists
license, connection limit, and replication support" says nothing new when the headers are right
there. A lead-in earns its place when it names the cases being compared, the units, the
assumptions, or an unusual way to read the table. A precise column label like "Median cold start
(ms)" is better than a vague "Speed" followed by a paragraph on what was actually timed.

Stop a section once its explanation is done. A trailing comparison, caveat, summary, or preview
belongs there only if readers need it at that spot.

## Heading patterns

Sibling headings that play the same role should match in grammar, in how specific they are, and in
which aspect they name. Pick one pattern for the set:

| Pattern | Fits | Example |
|---|---|---|
| Topic noun phrase | Concepts, specifications, estimates | "Idempotency keys for payment retries" |
| Question | Answering the reader's questions in turn | "What happens when a payment request is retried?" |
| Declarative clause | An argument built from supported findings | "An idempotency key makes a retried payment safe" |
| Instruction | Actions the reader will perform | "Send an idempotency key with every payment request" |

For technical explanations, short noun phrases naming the topic are the default unless another
pattern clearly does better. Whatever the pattern, the section has to deliver: answer the
question, back the claim within its stated conditions, or provide the promised steps. Matching the
form of headings is no excuse for vaguer ones.

Instruction headings suit a procedure even inside a conceptual piece. Headings that mark a standard
role in the document ("Introduction", "Conclusion", "References") keep their customary wording;
for generic role names, see SKILL.md `## Structure`.

Renaming a heading must not change the section's role or tone. A phrase abstract enough to head any
document is not more specific. Also make sure the new wording does not inflate a personal closing
remark into a universal lesson, or promise more than the section delivers.

Capitalize headings one way throughout, leaving proper names and acronyms untouched. If you number
sections, comparable sections share a numbering scheme, though a bibliography can go unnumbered.
Fix cross-references whenever headings are renamed or renumbered.

Read the headings by themselves: they should show the argument in order and treat parallel
sections alike. A new title tells readers the subject plus a contribution the document backs up or
a practical question it answers. Changes to the title and summary stay within what was asked.

## Main text, notes, and captions

In the body: the answer, the main reasons, the assumptions the conclusion relies on, and
representative examples that show the mechanism. In notes: supporting detail readers can skip
without misreading the main point. Material unrelated to the document goes nowhere. Choosing a
note mechanism, and collapsible notes in particular: `genres.md`.

For an overview, anything readers would use only to rerun a measurement or calculation moves to
notes: where coefficients came from, derivations, exact inputs, the environment something ran in,
cross-checks. A statistic shown in a table or figure need not be restated in the text. For a
tutorial, the steps and the conditions for doing them remain in the body. If a precise figure
requires lengthy setup that would break the main line of explanation, relocate both the figure and
the setup to a note and say in the body what the result means. A reader who skips the note must not
be left holding a wrong claim.

Every note needs a way in that tells readers what they gain by opening it: its link text, or the
sentence it is attached to. The note opens with that added evidence or explanation. Length is
acceptable when it helps readers check or build on a result; distinct topics get distinct entry
points.

From the body alone, without notes or captions, readers should get the answer and the main line of
reasoning. Say what a figure or table shows rather than repeating each of its numbers.

Number figures and tables in the form "Figure 1" and "Table 1" (a space between word and number),
and give each figure a brief, informative title. A caption says what is depicted and how to read
the relationship that matters, with an interpretation when one helps. Look at each figure or table
together with only its caption: it must still show what is plotted, the units, and the conditions
that make it readable, even when the body repeats them. Reproduction details live in notes unless
they alter what the comparison means. A detailed table may move into a note along with its setup.

### Alt text

Alt text exists to make the image's information available without the image. It keeps whatever
relationships and values serve that purpose, even when the body or caption already gives them.
Assess repetition separately for each route a reader might take: the text description of the image;
a figure or table read with its caption; the body read with a note; the body on its own. A fact may
need to appear on more than one route.

## Tables, lists, or paragraphs

Headings, lists, and tables help readers locate definitions, steps, and comparisons; reasoning that
hangs together belongs in paragraphs. Labels on list items and the short-list rule: SKILL.md
`## Lists`. Convert a list to prose when the prose shows the connections better and nothing readers
need becomes harder to find.

A table fits when readers weigh several items against the same criteria and lining them up in rows
and columns makes differences or patterns easier to see; database engines set side by side by
license, connection limit, and replication support are a typical case.

A list fits candidates that each stand out in their own way, or names that each come with a short
description. If a table's columns carry broad headers like "Features" or "Notes", check that the
cells really answer one shared criterion. Reasoning that readers must follow step by step, or
topics that lead into one another, call for paragraphs.

The deciding question: would the comparison or the relationships become harder to follow as a
list? Row and column counts alone do not settle it. Also weigh entry length, how the table behaves
on a narrow screen, and whether its borders and headers give the content more visual weight than
it deserves.
