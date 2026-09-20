# CV versus LB

## Fold spread as the noise floor

The per-fold scores in `metrics.json` give a spread (max minus min, or the standard deviation). A
CV improvement smaller than the spread is noise. The public LB uses a fraction of the test set
(recorded in `docs/competition.md`); its own noise is at least comparable to one fold's when the
fraction is small.

Read the CV vs LB table in `docs/validation.md` as pairs. Two patterns matter:

- Offset with the same ranking: CV and LB differ by a roughly constant amount, and experiments
  rank the same on both. The split is fine; the offset is a distribution difference or LB size.
  Keep trusting CV.
- Different ranking or a gap that grows with model strength: the split does not reproduce the
  test conditions, or a leak inflates CV. Investigate before the next experiment.

## Adversarial validation

Train a classifier to tell train rows from test rows on the features used by the model.

1. Label train rows 0 and test rows 1; stratified 5-fold; a small GBDT.
2. AUC near 0.5: no detectable shift. AUC well above 0.5: the top features by importance are the
   shifted ones; inspect their distributions in `notebooks/eda.py`.
3. Responses: drop or transform the shifted features; choose validation rows that look like test
   (weight or sample by the adversarial probability); or change the split (group or time) to match
   the mechanism that produced the shift.

## Changing the fold design

1. Write a `cv` Issue: current folds, problem observed with numbers, proposed change, how to verify.
2. Build the new fold file under a new name (`just folds <new-name> ...`). Do not delete the old one.
3. Rerun the reference experiments (the baseline and the current best) on the new folds; they are a
   new comparison table.
4. Add a row to "Fold version history" in `docs/validation.md` with the reason and the date.

## When to stop worrying

When the ranking of experiments agrees between CV and LB across several submissions, the split is
doing its job. From then on, choose final submissions by CV and treat LB as a check, not a target.
