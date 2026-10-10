# Digest format

Both digests hold what is known now, one section per topic. A finding is merged into its topic and
an outdated line is rewritten or removed, so the files stay short enough to read at every check.
Prose follows `CLAUDE.md` "Language and audience" (Japanese by default) under the template headings.

## Marker and counts

Right under the intro paragraph:

```
<!-- last-checked: 2026-10-10 -->
2026-10-10 時点で 90 スレッド、コメント 241 件を読んだ。
```

The SessionStart hook reads the marker; keep it on one line in exactly this form. The counts line is
for people and follows the docs language.

## docs/discussions.md

| Section | Content |
|---|---|
| Read first | At most five threads, the densest first: `### <id> <title>（<author>）` and two or three lines on why |
| Host answers | `- YYYY-MM-DD [<id>](<url>): <the answer in one or two sentences>`, newest first. Rulings also go into `docs/competition.md` |
| Open questions | Questions whose answer would change the plan; move a line to Host answers when answered |
| Data facts | Facts about the data that participants measured, with who measured them and whether we checked |
| Reported methods and results | Method, number, and source; "self-reported" until we reproduce it |
| Risks | Rule, runtime, or data risks to our submission |
| Resources | Datasets, models, and external data mentioned, each with its license |
| Skip | Thread ids not worth reading again (team hunting, chatter, answered duplicates) |

## docs/notebooks.md

| Section | Content |
|---|---|
| Lineage | Table: ref, votes, public score (API, or "self-reported"), role, built on. Forks sit next to their root |
| Approaches | What the strong lineages do, step by step, with the constants that matter |
| What ours lacks | Each gap with the kernel that has it and its measured or reported effect |
| Licenses and shared datasets | Datasets the kernels attach, their owners and licenses |
| Runtime | Reported run times and limits that constrain copying an approach |

## Diary diff (handed to kaggle-journal)

```
### 調査の差分
- 新しいスレッド: [<id>](<url>) <one line>、...
- 主催者の回答: [<id>](<url>) <one line>
- ノートブック: <ref>（公開 <score>）<what is new>
```
