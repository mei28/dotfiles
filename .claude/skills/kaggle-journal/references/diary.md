# Diary comment format

One comment per wrap-up on the diary Issue. Diary comments are in Japanese by default (`CLAUDE.md`,
"Language and audience"); the headings below are the Japanese defaults with English glosses.

## Heading

```
## 2026-10-10（27 日目、Early。Mid まであと 1 日）: <one-line headline, e.g. LB 0.339 -> 0.342>
```

- Day 1 is the competition's start date in `docs/competition.md`.
- Phase: Early before the 30% date, Mid before the 70% date, Late after it. Name the next phase and
  the days left; in Late, the days to the final submission deadline.
- A second wrap-up on the same day adds the time of day after the date: `## 2026-09-25（午後）`.

## Sections

Leave out a section that has nothing in it.

| Section | Holds |
|---|---|
| `### やったこと` (done) | One line per piece of work, with the commit hash, the Issue, or the doc path |
| `### わかったこと` (learned) | Findings with numbers and the view they were measured on |
| `### つまずいたこと` (stuck) | What cost time, and the fix or the open question |
| `### 提出` (submissions) | A table: experiment, what changed, public LB |
| `### 調査の差分` (research diff) | Only after `kaggle-research`: new threads and host answers by id with one line each, new kernels with their score and what is new |

## Rules

- Link instead of repeating: the details live in the idea Issue, the docs, or the explainer.
- Gloss an abbreviation the first time it appears in the comment.
- An explainer made in this wrap-up is embedded at the end:
  `![<name>](https://github.com/<owner>/<repo>/blob/main/docs/explainers/<name>.png?raw=true)`
  with the source path on the line above.
