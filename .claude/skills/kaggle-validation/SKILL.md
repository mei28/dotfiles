---
name: kaggle-validation
description: Design and audit cross-validation for a Kaggle competition in a waggle-based competition repository. Chooses the split from how the test set was built (time, group, multilabel, stratified, plain), builds and versions fold files under folds/, runs the leak checklist and the leak-reviewer agent, and compares CV with LB before a score is trusted. Use when choosing folds, when CV and LB disagree, before the first submission of a new model, or when the user says fold, CV設計, バリデーション, リーク.
---

# kaggle-validation

Make the CV score mean what it claims. The split must mimic how the test set was built, the fold
file must be shared by every experiment, and a score is trusted only after the leak checklist and
the CV versus LB table say why. Commands come from the template's `justfile` (`just --list`).

## When to use

- Before the first experiment of a competition (right after `kaggle-onboard`).
- Before the first submission of a new model family, and whenever fold or feature code changed.
- When CV and public LB move in different directions or the gap exceeds the fold spread.
- Not for scoring a single run: `kaggle-experiment` does that with `kgl.metrics.score_folds`.

## Decision flow

Read `docs/competition.md` (how the host split train and test) and the data before choosing.

```
Does the test set come later in time than train?      -> TimeSeriesSplit (sorted, never shuffled, warm-up fold -1)
Do test rows belong to groups absent from train?      -> StratifiedGroupKFold (bin a regression target with --stratify-bins)
Is it multilabel?                                     -> iterstrat.ml_stratifiers.MultilabelStratifiedKFold (uv add iterative-stratification)
Is the target categorical or imbalanced?              -> StratifiedKFold
Otherwise                                             -> KFold
```

`StratifiedGroupKFold` is preferred over `GroupKFold` because it accepts `shuffle` and `random_state`,
so fold assignment is reproducible. K: 5 by default; 3 for very large data, 10 for very small. When
the metric is noisy, estimate the fold spread first and pick K so the spread is below the effect you
hope to detect (see `references/cv-lb-gap.md`).

## Steps

1. Write "How the test set was built" in `docs/validation.md` with the evidence (data page,
   discussion, EDA of id or time ranges). If it is unknown, say so and pick the more conservative
   split (group over plain, time over group when both apply).
2. Choose the strategy and K with the decision flow. Record the reason.
3. Build the fold file with a name that encodes the design:
   `just folds <name> --strategy <S> --id-col <id> [--target <y>] [--group <g>] [--time-col <t>]`
   `[--stratify-bins 10] [--n-splits 5] [--seed 42]`, for example `skf5_seed42`, `sgkf5_user_seed42`,
   `ts4_month`. The file lands in `folds/<name>.parquet` with a
   JSON sidecar and is git-tracked. `save_folds` refuses to overwrite: a new design is a new name.
   Stage the two files together with `docs/validation.md` and propose the commit before the first full
   run, so the `git_commit` in `metrics.json` pins the fold version.
4. Check the fold properties and write them to "Fold diagnostics": per-fold size and target
   distribution (`polars` group_by), and `kgl.cv.check_folds(df, "fold", group=..., time_col=...)`
   for group isolation and time order.
5. Point experiments at the file (`Config.folds = "<name>"`). Every experiment compared in
   `docs/experiments.md` must use the same fold file; a different file is a different table.
6. Walk the leak checklist in `references/leak-checklist.md` against `run.py`, `infer.py`, and the
   feature code. Fill the table in `docs/validation.md` with status and evidence.
7. Run the `leak-reviewer` agent on the experiment before its first submission and when fold or
   feature code changed. Save its report as `docs/reviews/YYYYMMDD-<exp>-leak.md`; fix `high` items
   before submitting. The agent is registered only when the session was opened in the competition
   repository; from another working directory, give a general-purpose agent the body of
   `.claude/agents/leak-reviewer.md` as its instructions instead.
8. After every submission, add a row to "CV vs LB" (exp, run, cv, public lb, gap). When the gap
   exceeds the fold spread or CV and LB rank experiments differently, follow
   `references/cv-lb-gap.md`: adversarial validation, then a new fold version if the split was
   wrong, then rerun the reference experiments on the new folds.

## Notes

- Time strategies produce fold `-1` for warm-up rows; `kgl.cv.split(folds, k, time=True)` trains on
  folds below `k`. Plain strategies train on every other fold.
- Old fold files stay in `folds/` so old experiments remain reproducible. `docs/validation.md`
  keeps the version history with the reason for each change.
- Test-time statistics are fine only when the competition guarantees the same test rows at scoring
  time (CSV competitions); in code competitions the hidden test set can differ from the sample.
- The public LB is a small sample. Treat one LB value as a noisy measurement, not a verdict.

## Mistakes

- Chose `KFold` by habit when the data had users, patients, or sites appearing in only one of
  train or test.
- Regenerated `folds/<name>.parquet` in place after a preprocessing change; old runs became
  incomparable without anyone noticing.
- Fit a scaler, encoder, or target statistic on all rows before the fold loop.
- Selected features by importance computed on all rows, then reported the CV as if it were unbiased.
- Trusted a good LB to excuse a bad CV, or tuned to the public LB directly.

## Related skills

- `kaggle-onboard`: where the test-set construction is first written down.
- `kaggle-experiment`: uses `Config.folds` and records per-fold scores.
- `kaggle-submit`: adds the LB value that completes the CV vs LB row.

## Sources

- upura, "性能評価と検証" (evaluation-validation wiki page)
  <https://github.com/upura/everyday-kaggle-news/blob/main/docs/wiki/concepts/evaluation-validation.md>
- osushinekotan, ExpAgent validation-strategy reference
  <https://github.com/osushinekotan/ExpAgent/blob/main/.claude/skills/experiment-workflow/references/validation-strategy.md>
- sugupoko, fold versioning rules in kaggle_starterRepository
  <https://github.com/sugupoko/xxxx_kaggle_starterRepository>
- "Determining the K in K-fold cross-validation" <https://arxiv.org/abs/2511.12698>
- "Adversarial validation, explained" <https://www.kdnuggets.com/2016/10/adversarial-validation-explained.html>
