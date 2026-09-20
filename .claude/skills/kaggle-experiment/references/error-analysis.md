# Error analysis before tuning

Open the predictions before proposing the next change. The goal is a list of error groups with
counts, each pointing at a mechanism, not a list of hyperparameters.

## Procedure

1. Load `output/<exp>/<run>/oof.parquet` and join the raw training rows on the id.
2. Sample three sets: the 20 largest errors (`|pred - target|` or lowest probability of the true
   class), 20 borderline rows (predictions near the decision threshold), and 20 random correct rows
   for contrast.
3. For each sampled row note what the model saw (the feature values) and what would have made the
   prediction right. Do this by hand; this is the part that produces ideas.
4. Group the errors by mechanism, for example: missing values in a key column, a rare category,
   label noise, a distribution the training set lacks, a post-processing threshold, an id-order
   artifact. Count each group.
5. Check whether the groups differ across folds. A group concentrated in one fold points at the
   split, not the model.
6. Write the table into the Issue comment for the run and, when a group suggests a fold problem,
   into `docs/validation.md`.

## Table format

```
| group | count (of 60 sampled) | example ids | likely mechanism | candidate change |
|---|---|---|---|---|
| Age missing | 14 | 6, 18, 20 | imputation collapses to mean | age from title (Mr/Mrs/Master) |
```

## Turning groups into proposals

Each proposal names the group it addresses, the expected direction and size of the CV change
relative to the fold spread, and its cost (minutes to run, new dependency, new fold file). Offer two
or three; the user picks. A proposal that names no group is a guess.
