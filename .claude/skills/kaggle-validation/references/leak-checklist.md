# Leak checklist

For each item: what to look for, how to look, and what "clean" looks like. Record status and the
evidence (file and line) in the table in `docs/validation.md`.

| # | Item | How to check | Clean when |
|---|---|---|---|
| 1 | Test information in train | `grep -n "concat\|vstack\|test" experiments/<exp>/run.py`; any frame built from train and test together before features are fit | Test rows are read only in `infer.py`, or a concatenation is used for stateless transforms only (dtype casts, fixed maps) |
| 2 | Statistics fit outside the fold loop | `grep -n "fit(\|mean()\|std()\|quantile\|fit_transform" run.py`; check whether the call sits before `for k in run_folds` | Every fitted transform is fit on `X[tr]` inside the loop, or is a fixed mapping that does not read the data |
| 3 | Target encoding outside folds | `grep -n "target\|<target column>" run.py` inside feature functions | Target statistics are computed from out-of-fold rows only (`kgl.features.oof_target_encode` in later phases) |
| 4 | Feature selection outside folds | Importance, correlation, or univariate filters computed on all rows before CV | Selection happens inside the fold loop or on a held-out fold that is then excluded from the CV score |
| 5 | Time leakage | Features that use later rows (rolling windows centered or trailing into the future, `shift(-1)`); folds not time ordered; shuffled time strategy | Features use only past rows; `check_folds(..., time_col=...)` passes; the strategy is `TimeSeriesSplit` when the test set is later in time |
| 6 | Metric mismatch | Compare `kgl.metrics` entry with the evaluation page: averaging, thresholds, clipping, missing classes | A hand-computed test in `tests/test_metrics.py` reproduces a value from the competition text or a public kernel |
| 7 | Submission integrity | `grep -n validate_submission infer.py`; dtype of the prediction column; id order | `validate_submission` runs before writing; the dtype matches the sample |
| 8 | Fold file integrity | `Config.folds` names an existing file; `folds/<name>.json` matches `docs/validation.md`; `attach_folds` succeeds | Every training row receives a fold; the sidecar's strategy and parameters are the documented ones |
| 9 | Duplicate rows across split | Exact or near duplicates (same image hash, same text) in both train and test | Duplicates are grouped before splitting, or their presence is documented as a property of the test set |
| 10 | Id or order carries signal | Correlation of the id or file order with the target | Either excluded from features or documented as legitimate |

Typical evidence lines: `run.py:112 encoder fit on X[tr] only`, `folds/sgkf5_user.json strategy=StratifiedGroupKFold group=user_id`.
