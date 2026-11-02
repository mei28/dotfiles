# Claims and their evidence

Open this file when a document reports results, numbers, comparisons, sources, recommendations, or
caveats. It says how strongly each claim may be put and what must accompany it.

## Results, examples, and supporting numbers

Explain each result as deeply as the document requires: an overview shows the mechanism and its
consequence, while a document teaching a method follows the input through the key steps to the
output. Choose examples that represent the case well for that purpose, and tell readers what each
one demonstrates. Keep using one example while it still sheds light on why something happens,
which conditions count, or what to do, and make visible which information or action differs from
step to step. When you bring in another example, know which new distinction or relationship it
adds. Before folding examples together or dropping one, look at what each shows: its conditions,
its outcomes, its effect on readers. Two examples of one mechanism can still differ in a way
readers need for understanding or for a decision; keep a brief word on that difference.

A number or comparison stays if it backs a conclusion, explains a mechanism, bears on a choice, or
helps readers reproduce or check a result. Calculations the document never uses go, together with
how they were done. A value immediately followed by a warning that it does not answer the question
should make you ask why it is there. A counterexample showing where a metric fails is worth keeping
when that failure is the question.

## Quantities and calculations

Every number states its source (SKILL.md `## Claims`). Arrange prose, notation, and equations in
whatever order serves readers: a specification may define first and explain the symbols after,
while an introduction may need intuition or a worked case before any formula.

For any quantity the conclusion rests on, tell readers what was measured or computed and what it
is measured against:

| Kind of value | Say | Example |
|---|---|---|
| Average | What it is averaged over (a period, a population, some other base) when that changes the reading | "120 requests per second, averaged over business hours", not "120 requests per second on average" |
| Fraction or per-unit value | The denominator and what it includes, such as whether idle capacity counts, when that matters | "Errors per 1,000 requests, counting each retry as a request" |
| Several values | Whether they are separate cases, bounds, an observed range, or an uncertainty interval; what varies and what is held fixed | "p50 and p99 latency at 200 concurrent clients, same hardware" |

Whatever readers need to interpret a result goes in the body or the table header. If a read-heavy
profile needs 6 nodes and a write-heavy profile needs 14, attach each number to its profile. A bare
"6–14 nodes" reads as a lower and an upper bound when it is really two cases.

When readers would otherwise have to guess how a formula works, say what each term and operation
does. For example: to get the net monthly cost, take each region's committed-use credit off that
region's bill, then total the regions. Whether that explanation comes before or after the equation
depends on what readers already know.

Editing a calculation must leave intact the direction of every comparison, the sequence of
operations, the units, the ranges, and the quantifiers. Exact values stay distinct from
approximations, bounds from typical values, per-case figures from averages. Edge cases that bear on
the conclusion or its use stay in. Making a sentence read more smoothly never licenses turning a
condition that suffices into one that is required, or "can happen" into "will happen".

## Interpretations at the strength the evidence supports

Definitions, verified facts, and what follows from them are stated flatly, within their scope.
Possibilities, inferences, and predictions take "may", "suggests", or "I expect" as appropriate.
"Can" marks a capability, or behavior that shows up for some inputs and not others: if a queue
loses messages only under one acknowledgment mode, keep "The queue can lose messages"; "The queue
loses messages" is a different claim.

An interpretation tells readers what an observation backs up and on what grounds. "Consistent
with" says the observation fits an explanation, not that the explanation is the cause. "The 429
responses are consistent with rate limiting" becomes a different claim as "The operator throttled
the endpoint on purpose": it adds a cause and an intent nobody observed.
Uncertain mechanisms are worth discussing when they help answer the document's question, provided
they stay visibly separate from what was observed.

When rewording, carry over each claim's reasons and evidence unchanged. A different reason that
happens to reach the same conclusion is no substitute: "We pinned the library to 2.x because 3.0
drops Python 3.9" and "We pinned the library to 2.x because 2.x is more stable" give different
grounds for one choice. If an explanation has a gap, fill it by adding the missing link to the
original reasoning, not by replacing the reasoning.

| Evidence in hand | What you can write | What to keep in view |
|---|---|---|
| A formula with its assumptions spelled out | The result it yields, stated plainly as holding under those assumptions | It says what the math predicts, not what a running system did. |
| A configuration file or a specification | "The configured maximum is 500 connections." | The declared ceiling is not the heaviest load anyone tested. |
| Measurements on particular inputs | "On these three datasets, the Rust parser finished before the Go parser." | Say which inputs the comparison covers. Exact inputs and procedure go in a note unless they change the reading. |
| An observation more than one mechanism could produce | "Lock contention would explain this; the traces do not separate it from GC pauses." | List only the alternatives the evidence makes plausible. |
| A reduced or simplified test | What that reduced test demonstrates | Do not fold it together with a full-system run into a statement that the full system passed both. |

A comparison reaches no further than its evidence. "Lower latency on the read-only benchmark" says
less than "lower latency", and an asymptotic bound is not a measured runtime. Halving the number of
HTTP requests does not by itself halve page-load time: requests differ in size, and some run in
parallel. Keep the workload and the quantity compared explicit. The same goes outside software: a
shorter commute distance does not by itself mean a shorter commute.

Show how a design choice produces the benefit claimed for it. Batching writes cuts disk syncs only
when writes arrive faster than the batch interval. Tell apart what the proposal shares with
existing methods and what it contributes that is new. Words like "robust", "stable", "optimal", and
"significant" need a definite meaning and evidence matching that meaning. Evaluative words such as
"excessive", "fair", or "desirable" need the goal or yardstick behind them. A summary may claim no
more, and under no looser conditions, than the body has shown.

## Sources and attribution

Confirm that each cited source exists, says what you cite it for, and covers the conditions you
attach. A single study cannot carry "researchers agree" or "many studies show". If a conclusion
lacks support, fix the conclusion; hedging it with "may" or a disclaimer is not a fix.

A claim shown to be false and a claim whose source you could not confirm are different cases. For
the second, tell the author what remains unresolved; do not make up a citation, and do not quietly
delete the claim as if it were disproved. Every factual correction comes with its evidence.
Failing to find something does not show that it is confidential or unpublished.

## Recommendations and time points

Recommendations and facts that go stale, such as prices, timetables, and what a venue offers, need
the date or period that makes them interpretable and usable, plus a note on what readers should
confirm before they act. Decide whether a year, a month, or a full date is the right precision. A
full date belongs in the body when a few days' difference changes the meaning, as with the day a
price change takes effect. The dates on which you checked individual facts can sit in the sources,
notes, or methods. Do not restate timing the surrounding text has already made clear.

Example: "As of October 2026, the free plan allows three private projects. Check the pricing page
before moving a team onto it."

Price ranges, selection criteria, and affiliate links: `genres.md`.

## Defensive qualifications

Goal language ("is designed to", "aims to", "is intended to") fits a goal that evidence supports,
even when nobody has yet confirmed that the goal is met: "The scheduler is designed to keep each
worker under 80% CPU." When a definition or a verified result already shows the behavior, say it
as fact: if the code caps assignments at four, write "The scheduler assigns at most four jobs per
worker." Describing an established behavior as a goal undersells it.

Lay out the assumptions that apply throughout at the top of the document, section, or example,
and from then on state consequences without hedging. Repeat a condition only when the topic shifts
or when dropping it would change what readers take away. While the scope stays obvious, delete
refrains such as "under these conditions".

To test a caveat or a negative clarification, take it out temporarily, and read the negative
statement alongside the positive account of the scope, source, method, or subject. It stays if its
absence alters the claim's scope or certainty, or if it heads off a particular misreading that the
positive account leaves open and that would change what readers understand, decide, or do. Collect
repeated formulas such as "A by itself does not settle B" or "this still needs checking" and look at
them side by side, to see whether they really do different jobs.

| What the statement is doing | What to do |
|---|---|
| Alters how readers can use the result | Leave it next to the claim, plus its reason if readers need one. |
| Restates an assumption that plainly still applies | Keep the assumption where it was set; delete the restatement. |
| Repeats in negative form a distinction the positive account already draws | Delete it, unless it clears up some specific ambiguity that remains. |
| Compensates for a claim or label that went too far | Fix the claim or label itself first, then keep any condition still needed. |
| Rejects a stronger claim nobody made or needed | Delete the rejection, and any material that was there only to support it. |
| Flags an open question at the heart of the document | Say what is not yet known and, if helpful, what observation would answer it. |
| Merely notes that further research is possible | Delete it. |

Examples. Once the basis of a projection is stated nearby, "This figure is projected, not observed"
can shrink to "The projected peak is 3,200 requests per second." A premise like "If every region
fails over within 30 seconds, ..." already marks what follows as hypothetical, so no extra
disclaimer about real failovers is needed. Rewriting a negative claim as a positive one must keep
its scope: learning that cache size by itself does not explain a slowdown says nothing about
whether cache size and thread count together explain all of it.

## Judgments, disclosures, and editing work

Every judgment comes with its grounds and its consequences: which comparison would tip a choice,
which edge case would break an implementation. "This matters" asserts a connection without showing
it. True disclosures of tools or help stay in, including whether the author checked an analysis
independently.

Checks you made while editing are one thing; what readers need to know is another. Mention
formatting, conversion, or verification work only if omitting it would change how readers
interpret the material, or if the publication demands it. If "The logs are shown as captured"
already tells readers what they are looking at, do not add that the lines were rewrapped to fit
the page. Do tell readers about omissions, data selection, and other processing that change how
the material should be read: "Two runs that crashed during warm-up are excluded."
