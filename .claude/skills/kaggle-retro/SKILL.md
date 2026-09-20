---
name: kaggle-retro
description: Run the post-competition retrospective for a waggle-based competition repository. Compares CV, public LB, and private LB per submission, lists what worked and what did not with experiments as evidence, then turns the lessons into changes to the waggle template repo, the kaggle-* skills in dotfiles, and notes on the nvidia-kaggle plugin. Use after a competition ends, when the private LB is released, or when the user says 振り返り, retro, 反省会, テンプレートを更新.
---

# kaggle-retro

Close a competition by writing `docs/retro.md` from the records, then carry the lessons to the two
places that outlive the repository: the template at <https://github.com/mei28/waggle> and
the `kaggle-*` skills in `~/dotfiles/.claude/skills`. The template changes after competitions, not
during them; this is the moment.

## When to use

- The competition ended and the private LB is visible.
- The user wants to stop working on a competition and keep what was learned.
- Not for mid-competition course corrections; those are `cv` or `idea` Issues.

## Steps

1. Gather the records: `just exp-table`, `docs/submissions.md`, `docs/validation.md` (CV vs LB
   table), `gh issue list --state all --label idea`, `gh issue list --state all --label cv`, and
   `kaggle competitions submissions -c <comp>` for private scores. Add the private LB to each
   submission row.
2. Fill `docs/retro.md` section by section using `references/retro-questions.md`: result and
   shake-up, phases (planned dates versus when the baseline, the diverse models, and the ensemble
   actually happened), decisions and their outcomes (each closed Issue: kept or dropped, and what
   the experiments showed), what worked and what did not with experiment names as evidence.
3. Compare with the top solutions: fetch the winners' writeups with the `nvidia-kaggle` skill and
   list the two or three differences that explain most of the gap. Note which of them were visible
   in prior art at onboarding time.
4. Template review. From the friction log (things typed by hand, recipes that were missing or wrong,
   modules copied between experiments, tests that were missing), write the list of changes to
   `waggle`. Make each change in the template repository as its own commit with tests for
   `src/kgl` (`tdd` skill), present the commits for approval (`commit` skill), and push after approval.
5. Skills review. For each `kaggle-*` skill: did it trigger when it should have, which steps were
   wrong or missing, which references were read and which never were. Edit the skills in
   `~/dotfiles/.claude/skills/kaggle-*`, run the skill-creator validator on each, and present the
   commits for approval.
6. Plugin review. Which `nvidia-kaggle` workflows were used, what failed, what was missing. Write it
   into `docs/retro.md`; open an upstream issue only when the user asks.
7. Put the final result (rank, medal, CV and LB of the chosen submissions) at the top of the
   competition repository's `README.md`, and stop.

## Notes

- Evidence over impressions: every "worked" or "did not work" names an experiment and a number.
- Keep `docs/retro.md` in the competition repository; the template and the skills receive only the
  generalized change, not the competition story.
- If the same friction appears in two retrospectives, it is a template or skill defect, not a habit.

## Mistakes

- Wrote the retrospective from memory without `docs/experiments.md` and the Issue history.
- Changed the template during the competition and lost track of which version each repo used.
- Recorded lessons in the retro file only, so the next competition started from the old template.
- Reviewed the template but not the skills, so the procedure drifted from the code.

## Related skills

- `kaggle-onboard`: the next competition starts from what this retrospective changed.
- `commit`, `tdd`: for the template and skill changes.

## Sources

- upura, "実験管理" and "マインドセット" wiki pages
  <https://github.com/upura/everyday-kaggle-news/tree/main/docs/wiki/concepts>
- rsakata, "shake-upを科学する" <https://speakerdeck.com/rsakata/shake-upwoke-xue-suru>
