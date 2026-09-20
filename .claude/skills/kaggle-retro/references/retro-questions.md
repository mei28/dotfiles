# Retrospective questions

Answer with numbers and experiment names. Skip a question only when it does not apply, and say so.

## Result

- Final public and private rank; medal or not. Which two submissions were chosen and why.
- Shake-up: for each submission, public LB, private LB, and CV. Did CV predict private better than
  public did? Which fold design was in use for each?

## Phases

- Planned 30% and 70% dates versus the dates of: the first end-to-end submission, the first strong
  baseline, the third diverse single model, the first ensemble.
- Which phase took longer than planned, and what consumed the time (environment, data understanding,
  a wrong CV, tooling).

## Decisions

- For each closed `idea` Issue: outcome (kept, dropped, inconclusive), the experiments that decided
  it, and whether the decision would be the same with the private LB known.
- For each `cv` Issue: did the change close the CV vs LB gap? What did adversarial validation show?
- Which decision was made late that should have been made in the early phase, and what information
  would have allowed it earlier.

## What worked / did not

- Feature or data changes with the largest CV gain, and their cost.
- Model families tried, best single-model CV of each, and their contribution to the ensemble.
- Ideas from prior art that transferred, and those that did not (with a guess why).

## Top solutions

- Two or three differences between the winners and this solution that explain most of the gap.
- Which of them were visible in discussions or past writeups at onboarding time.

## Template friction

- Commands typed by hand that should be recipes.
- Code copied between experiments that belongs in `src/kgl` (with the test it should have).
- Recipes or tools that failed or behaved differently from their description.
- Missing artifacts (things you wished were in `metrics.json` or `output/`).

## Skills

- Which `kaggle-*` skills triggered on their own, which had to be invoked by name, which never fired.
- Steps that were wrong, missing, or in the wrong order. References read versus never opened.
- Rules in the repository `CLAUDE.md` that helped, that were ignored, that got in the way.

## Plugin

- `nvidia-kaggle` workflows used (competition details, writeups, discussions, kernels, submission).
- Failures, missing features, and whether the research it produced was used in Issues.
