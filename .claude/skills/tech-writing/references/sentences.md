# Sentences, terms, and notation

Open this file for sentence-level work: linking clauses, pacing, trimming without dropping
meaning, bringing in terms, picking words, pronouns and self-reference, and English typography.

## Making relationships explicit

Voice is set in SKILL.md `## Sentences`.

Watch the point where the text turns from background facts to what this document or its author
investigates, compares, or explains. Readers must still know what is being discussed and who is
doing it; if the turn leaves that open, name the subject. Mention the document itself ("this
guide") only where a sentence needs it. An introduction owes readers the question being answered
or the reason the subject deserves attention; a list of what the document plans to do supplies
neither.

Make subject, verb, and complement carry the relation you intend. Put whatever acts, or whatever
has the property, in subject position: "The compressor uses most of the CPU during backups" names
the consumer, and "Backups need a lot of CPU" leaves it out. When comparing, keep both sides the
same kind of thing, such as two throughputs or two programs, never one program set against the
other one's throughput. Headings and summaries get the same check.

If a single subject carries a chain of verbs, confirm that it really performs each step. An event
that sets processing off is not the component doing the processing: "A push triggers the
pipeline, which builds and deploys the image", not "A push builds and deploys the image". Bring
the component back into the sentence when leaving it out obscures who does a step or the order of
steps. Familiar shorthand can stay when the context already shows who acts and in what order.

Before the next claim, spell out any link readers would otherwise have to work out alone. Once
wall-clock time and CPU time have been told apart, say which of the two the benchmark table
reports and which the cost estimate relies on. Start from what the context has already settled,
and check any claim still open before building an explanation on top of it.

Pick "because", "so", "although", or "whereas" according to how the statements really relate. A
source placing two facts side by side has not shown that one causes the other. Delete
"Furthermore", "Importantly", and similar words wherever they link nothing.

Write alternatives in matching form: "Option A validates input in the browser and checks it again
on the server. Option B skips the browser check and validates only on the server." Because the
two sentences share a frame, the single difference, where validation runs, stands out. Add what
that difference leads to when the current question depends on it and the context has not said so.

A comparison of size, rank, growth, decline, success, or failure names both sides and the basis.
When the outcome depends on conditions, say how. Wording such as "the ranking flips" or "the trend
reverses" has to make plain what grows, which option comes out larger, or whose rank changes:
"Above 64 KB, gzip produces smaller output than zstd at its default level." Follow the definitions
of any signs or directions you use.

After "this", add a noun whenever the referent could be misread: "this limit", "this retry", "this
mapping". Say a technical term again when precision depends on it; a near-synonym swapped in to
avoid repetition can make readers think a second concept has appeared. Items in a list share one
grammatical shape and one level of detail, and a verb or modifier they share must fit every item,
in grammar and in meaning.

The material sets the number of items. Hold criteria and conditions steady across alternatives,
yet let each one take as much room as its evidence warrants. Cut any item that exists only to hit
a target count or to make the sides look even.

## Rhythm through meaning

Read adjacent paragraphs as one unit, out loud if that helps you hear a sentence shape coming
back. Some recurring patterns signal that one explanation appears twice: sentence after sentence
opening "The X ...", actions as grammatical subjects ("Doing X causes Y"), clause pairs around
semicolons, conclusions led by "so" or "therefore". Merge the duplicated explanation first; adjust
openings and punctuation only after that.

Let the content of each sentence set its length, and ignore character-count targets taken from
Japanese style guides. A result can stand in a short sentence, while a reason or condition is
better kept in the same sentence as the claim it qualifies. When it matters who acts, put that
actor first: "The scheduler skips jobs whose owner has left the team" beats "Owner departure causes
jobs to be skipped". An action can be the subject when the action itself is the topic, and a
semicolon is fine when it lines up parallel alternatives for comparison.

Pick predicates that signal whether a sentence defines something, describes a state, reports a
change, or gives what follows from a stated condition. If a sentence starts from a condition or an
operation, its main clause must deliver the consequence you meant. Where the link is murky, try a
clause that names the action or outcome in place of a noun phrase, and keep whichever reads more
clearly. A computed or hypothetical result must never read like an observed change.

Go from what readers already have to what is new, even if that starts consecutive sentences with
the same word. Break a sentence up when it asks readers to juggle too many relations at once; join
two when that makes a condition, cause, or contrast easier to follow. Neither an overloaded
sentence nor a string of unconnected short ones serves readers. Questions, fragments, and unusual
punctuation belong only where the voice and purpose call for them.

When a noun carries several conditions, or conditions combine with a negation, draft an
alternative that gives the subject, the conditions, and the action one at a time. Keep whichever
version a reader can parse on the first try, even if it runs longer. "Requests not exceeding the
quota from clients without a key are not logged" becomes "Requests from clients without a key are
not logged unless they exceed the quota."

## Removing padding while preserving meaning

Settle which explanations stay before trimming any single sentence. Shortening can backfire: a
compact phrase may introduce a term readers do not know, or bury a step of reasoning. For each
cut, ask whether the deleted words told readers who acts, how far a term reaches, or which
statement a condition belongs to. If the cut forces readers to guess at a relation the original
stated, put the words back. Fewer words is not an improvement in itself, and a requested length is
a constraint to honor. Where a longer form draws no extra distinction, prefer the direct one:

| Before | After |
|---|---|
| On account of the fact that the token expired, the request fails. | Because the token expired, the request fails. |
| The script carries out a validation of the schema. | The script validates the schema. |
| The cache is warmed for the purpose of avoiding cold starts. | The cache is warmed to avoid cold starts. |
| It should be noted that the quota resets at midnight UTC. | The quota resets at midnight UTC. |
| This page serves as the reference for the CLI flags. | This page is the reference for the CLI flags. |
| The dashboard features a dark mode. | The dashboard has a dark mode. |

Prefer "is", "are", or "has" for saying what something is or contains. "Serves as" and "acts as"
earn their place when they mark a role, a behavior, or a temporary assignment rather than
identity: "During the migration, the replica acts as the primary."

For every "not X but Y", "not just X but Y", or contrast split over two sentences, ask what each
half adds. "This isn't merely a linter. It's a way to enforce your conventions" can become "The
linter enforces the team's naming conventions." Retain the negative half when it corrects a
misreading readers are likely to make, or draws a line they need. Drop the contrast when its only
effect is to inflate the positive claim.

Look for several words naming one thing inside a sentence or across neighbors. If "logs",
"output", and "traces" all mean the same file, "Send us your logs so we can read the output and
diagnose the traces" can become "Send us your logs so we can diagnose the failure." When the words
name different material or play different roles, keep them apart.

Where a sentence announces that something is important or praises it vaguely, replace that with
what changes, when, and why it matters, backed by evidence. Name the operation with a concrete
verb: "retries", "evicts", "serializes". Cut intensifiers like "dramatically" that take the place
of evidence.

"Use" beats "utilize" when the two mean the same. Technical verbs carry distinct claims, though:
"prove", "estimate", "approximate", and "suggest" each say something different from "show", and
none of them can stand in for another.

Once a passage is shorter, recheck who acted, what brought the result about, and what was actually
finished. "The team started evaluating a move to Postgres" does not mean "The team moved to
Postgres". Intentions, attempts, work in progress, and finished results must stay
distinguishable, and so must the original conditions and the attribution.

## Terminology and definitions

Bring in a term at the point where readers need it to understand an object, an operation, or a
result. A term that appears in the introduction is often easier to explain later, where it is put
to use. If the operation is what the passage is about, describe the operation and give its name
together. Phrases like "hereafter called X" are worth keeping only when readers need the name
right there.

"Rounding each timestamp down to the start of its minute groups events into one-minute buckets"
already defines bucketing by showing what is done and what comes out. Following it with "This is
called bucketing" names the thing twice without adding understanding, and moving that clause into
the prior sentence or into parentheses does not remove the duplication.

Sometimes a description of the operation is all readers need. "Each retry waits twice as long as
the one before" tells readers what "exponential backoff with factor 2" means and sets up a later
sum of the waiting times. If the name will come up again, keep it.

Swapping a technical term for plain words is safe only if the plain words keep every object,
condition, and property the term pins down. When the plain version means something broader, keep
the term and add an explanation. Replacing "atomic write" with "saving the file" loses the
guarantee that the file ends up with the old contents or the new ones, never a mix.

Write a standalone definition when the passage is about the meaning, scope, or distinction itself;
specifications and notation sections are the usual cases. Formal definitions can open with "Let
..." or "Here, ... denotes ...".

After introducing a term, stick to it. If its meaning later widens or splits, explain the change at
that point. Restate a definition in any passage that depends on it and may be read in isolation.

Spell out unit conventions and data representations wherever a misreading would alter a
calculation or an implementation, and do so even for experts: MB versus MiB, seconds versus
milliseconds since the epoch. If a specialized statistic carries weight, the body tells readers
what its value means.

Say how far each definition and convention reaches. When a choice belongs to one method or model,
flag it, so readers do not mistake it for a property of the concept itself.

Prefer terms that English-speaking practitioners already use. Introduce an unfamiliar acronym where
it starts to pay off, and skip acronyms that appear only once. Treat common technical nouns and
official names differently: an English sentence capitalizes by English rules, not by how a
Japanese glossary styles the term. Code identifiers, symbols, API names, and product
names are reproduced exactly.

## Word combinations

An English word is judged on three counts: what it means, which words it normally pairs with, and
whether it suits the readers. Look at the whole phrase, a verb together with its object and
preposition, a noun together with its modifiers. Something that would sound odd rendered into
Japanese can be plain English, so a word list made for another language, the Japanese lists in
`../../japanese-tech-writing/` included, has to be re-checked before it is applied to English.

Unpack an abstract noun-plus-verb into the concrete act, to see who does what to what. Approving a
vendor, signing its contract, paying its invoice, and setting money aside for it are four
different events, and "We secured hosting" could mean any of them. Rewording must keep a plan, an
assumption, and a finished action distinguishable.

## Articles, number, and quantifiers

Every article, plural, and quantifier is a decision. "A config file" introduces one possible file;
"the config file" points to one already identified. "Every worker", "at least one worker", and "the
workers in this cluster" make three different claims. Japanese often leaves number and
definiteness unmarked, so look at these choices closely when translating from it.

## Voice, person, and self-reference

Prefer everyday verbs and concrete description. Fix a tone that fits the document's purpose, and
hold it across passages that do the same job (SKILL.md `## Sentences`). Neutral prose usually suits
definitions and specifications.

A style sample shows how its author picks words, how formal they are, how far they explain, and
how their paragraphs unfold; read it for those things. Instructions given for this document
override any habit you infer from the sample. Matching its sentence lengths or punctuation counts
misses what makes the style. Do not let the sample's facts, experiences, or opinions slip into the
draft as if they were the draft author's. With no sample, preserve whatever in the draft is
already clear and whatever stylistic choices look intentional.

Write "I" for the author's own decisions, experience, and argument, "my" for the author's own
work, and "we" or "our" for a group that has been named. "We" can also take the reader along
through a derivation ("We can now drop the constant term"); keep that inclusive use from blurring
into statements about what a team did.

Japanese self-reference becomes these pronouns in English. Do not keep repeating the author's
name, and do not write "the author" or "this author". A family's experience is "our family".

These pronoun rules govern new writing and translation. When revising an existing English
document, keep the self-reference it already uses, "the author" included, unless it is wrong or
inconsistent within the document. Changing a deliberate voice has no benefit you can name, so the
revision procedure would revert it anyway.

When discussing publications, keep the author's role visible. "My earlier paper" may cover a
coauthored paper; switch to "our earlier paper" once readers know the coauthors. State lead
authorship or coauthorship when it matters and the facts support it. If a lead author refers to
their own paper, rewording that as "a paper I contributed to" conceals their role.

Refer to "this guide" or "this document" when stating its purpose or scope helps; otherwise just
make the point. Delete announcements that duplicate what nearby text already says. A preview may
still be doing work, though: giving the author's motive for writing, speaking to the reader, or
marking a change of topic. Check for that before deleting it. "This bug has bitten me twice, so
here is the fix I now try first" ties an experience to the reason for sharing it. Rewriting such a
line as a flat report of the author's actions can drop the invitation it extended.

Aim for idiomatic English that readers from many countries can follow. Common word pairings beat
slang and cultural references that would need explaining. Personal reviews: `genres.md`.

## English notation and local context

- Follow English spacing and punctuation: a space between words, after commas and sentence-ending
  marks, and after a colon; ordinary round parentheses. Full-width Japanese punctuation has no
  place in English prose. Code and mathematical syntax keep their own rules.
- Hyphenated compound modifiers such as "read-only replica" are fine where convention uses them to
  make the grammar clear. Do not stack nouns into a compressed chain when a clause or a
  prepositional phrase would read more easily: "session token refresh failure handling" → "how
  the client handles a failed token refresh".
- Write numbers and units the conventional way: "16 GB", "250 ms", "15%". Leave the units and
  precision of the claim as they were.
- Write dates so they cannot be misread: "March 3, 2027" in prose, or ISO 8601 ("2027-03-03") in
  tables, logs, and changelogs. "03/04/2027" means different days to different readers.
- Keep math notation, code, and prose visibly different. Identifiers get code formatting; emphasis
  marks a distinction readers must not miss; ordinary technical terms need neither.
- Break words where English breaks them. Delete manual line breaks that split ordinary words, and
  rethink phrase groupings inherited from the source language.
- When readers need to know the country, currency, institution, or service, name it. Keep the
  original setting and the author's own experience rather than swapping in something more familiar
  to English readers. Use the established English name of a thing, but leave official titles and
  bibliographic attribution intact.

These conventions also cover metadata, notes, captions, labels, alt text, and interface controls.
