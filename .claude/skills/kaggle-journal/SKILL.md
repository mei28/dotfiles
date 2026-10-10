---
name: kaggle-journal
description: Keep the running records of a waggle-based competition repository current in one wrap-up - the diary Issue, the CV vs LB tracking Issue and its figure, docs/glossary.md and the pinned Glossary Issue, picture explainers, and docs/roadmap.md. Offers the wrap-up on its own after an LB is recorded, while a long run is going, after a research check, and at the end of work, asking once with the list of targets, then goes through to the push and the Issue updates. Use also when the user says 日記, 一括更新, ドキュメントと issue を更新, 図解, eli18, 用語集, or ends the day with 今日はここまで.
---

# kaggle-journal

Besides the experiment records, a competition repository keeps three running records: docs (facts
that later decisions depend on), Issues (one per idea, plus three tracking Issues), and the diary
(what happened when). This skill updates them together in one wrap-up, so the user does not have to
ask for it after every step. Language and reader level come from the "Language and audience" section
of the repository's `CLAUDE.md`.

## When to use

- A checkpoint was reached. Offer the wrap-up when an LB was just recorded in `docs/submissions.md`
  (`kaggle-submit`), when a long run is going and the session is waiting (`kaggle-experiment`), when a
  research check finished (`kaggle-research`), or when the user signals the end of work.
- The user asks for the diary, docs, and Issues to be updated, for an explainer, or for a glossary
  entry. Run the same wrap-up.
- Not after a debug run or a variant: `just record` already wrote the idea Issue comment.

## Tracking Issues

`kaggle-onboard` creates them; their titles and bodies are in `references/tracking-issues.md`. Find
the numbers with `gh issue list --search "<title> in:title"`.

| Issue | Label | Pinned | Holds |
|---|---|---|---|
| Diary | `log` | yes | one comment per wrap-up, for the whole competition (never one per phase) |
| Glossary | none | yes | the body is `docs/glossary.md`, replaced whole |
| CV vs LB | `cv` | no | the figure, its legend, and dated notes on submissions that left the line |

## Steps

1. Collect what changed since the last diary comment: its date (`gh issue view <diary> --comments`),
   `git log --since=<date>`, new rows in `docs/submissions.md` and `docs/experiments.md`, Issues
   updated since then (`gh issue list --state all --search "updated:>=<date>"`), and the research
   diff when `kaggle-research` ran.
2. Write the plan, one line per target:
   - docs: the CV vs LB row in `docs/validation.md`, new terms in `docs/glossary.md`,
     `docs/roadmap.md` when the proposed order or the decisions for the user changed, and the other
     docs touched since the last wrap-up
   - figure: `just cv-lb-plot` when a new LB row exists
   - explainer: only when a new method or a new term landed since the last wrap-up, named
     ("explainer: exp015 derived candidates")
   - Issues: the CV vs LB body, the Glossary body, idea Issue comments beyond `just record`
   - the diary comment
   - the commit message and the push
3. Ask once: show the plan and ask whether to run it. The user may drop lines. This one answer covers
   the commit, the push, and the posts for the listed targets. Anything not on the list needs a new
   question.
4. Docs and files first: edit the docs, run `just cv-lb-plot`, write and render the explainer
   (`references/explainers.md`). Commit through the `commit` skill's grouping, then push.
5. Issues after the push. Images in Issues load from
   `https://github.com/<owner>/<repo>/blob/main/<path>?raw=true` and break until the file is pushed.
   - CV vs LB: refresh the body (`references/tracking-issues.md`). Add a dated note when the new
     point left the line by more than the LB noise, or when it changed how the CV is read.
   - Glossary: `gh issue edit <n> --body-file docs/glossary.md`.
   - idea Issues: comments for findings that `just record` did not carry; the explainer image on the
     Issues of the idea it explains.
6. Diary last, in the format of `references/diary.md`. Link the commits, the Issues touched, and the
   explainer, so the diary is the index of the wrap-up.
7. Report the links of everything posted.

## Notes

- Glossary: add a row the first time a term appears in docs, Issues, or a reply. Never edit the
  Issue body by hand; it is the file. When the file nears the Issue body limit (65,536 characters),
  propose an Issue that only links to the file.
- Roadmap: when it changes, refresh "Where we are" in the same edit. Its "Decisions for the user"
  list is where a wrap-up puts the open decisions; the wrap-up itself decides nothing (the decision
  gates in `CLAUDE.md` still apply).
- Diary: what grows moves out. An idea to test becomes an `idea` Issue after the user agrees; a fact
  that later decisions depend on goes into `docs/*.md`. The diary keeps a link.
- The day number and the phase in the diary heading come from the start date and the 30% and 70%
  dates in `docs/competition.md`. There are no GitHub milestones.

## Mistakes

- Posted Issue images before the push; they showed as broken links until the next wrap-up.
- Edited the Glossary Issue by hand; the file and the Issue drifted apart.
- Made an explainer for every experiment, including variants that changed nothing.
- Asked for approval per Issue; the user wants one question per wrap-up.
- Posted to an Issue that was not on the plan the user approved.
- Opened a new diary Issue when the phase changed.
- Waited for the user to ask for the wrap-up after the LB came in.

## Related skills

- `kaggle-submit`, `kaggle-experiment`, `kaggle-research`: their checkpoints offer the wrap-up.
- `kaggle-onboard`: creates the tracking Issues.
- `commit`: grouping the docs commit. `dataviz`: charts inside an explainer.

## Sources

- The diary (#21), Glossary (#23), and CV vs LB (#27) Issues of mei28/enveda-casmi26, 2026-09 to
  2026-10, where this routine was requested by hand seven times in two weeks before it became a skill.
