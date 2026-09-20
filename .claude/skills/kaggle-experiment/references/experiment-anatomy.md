# Experiment anatomy

`experiments/expNNN_change/run.py` and `infer.py`, as laid out in `exp000_baseline`.

## run.py, top to bottom

1. Docstring header, read by tools:
   ```
   """exp013_target_enc: out-of-fold target encoding on Cabin deck.

   base: exp012_lgbm_te
   hypothesis: deck carries survival signal that raw Cabin strings hide
   issue: #14
   """
   ```
2. `ModelParams` and `Config` dataclasses. Every tunable lives here. Nested dataclasses become
   dotted flags (`--model-params.num-leaves 31`); `dict` fields are not supported by tyro.
   `Config.from_dict` rebuilds the nested objects from `config.json`.
3. Feature functions registered by name (`@register("basic")`) and `build_features(df, cfg)` that
   concatenates the ones named in `Config.features`. Encodings are fixed maps or fit inside the fold.
4. `load_train`, `load_test` via `kgl.env.comp_dir`, so paths work locally and in the kernel.
5. `fit_fold(X_tr, y_tr, X_va, y_va, cfg)` returns the trained model; `predict(models, X)` averages
   fold models; `postprocess(pred)` maps to the submission's value type. `infer.py` imports these.
6. `main(cfg)`:
   - `detect()`, `run_id(sys.argv[1:])`, `run_dir`, `get_logger`, `seed_everything`, `write_config`.
   - Attach folds from `folds/<Config.folds>.parquet`; read the sidecar to know whether the strategy
     is a time strategy (`kgl.cv.split(..., time=True)` trains on earlier folds only).
   - `--debug`: first fold only, small head of the data, `output/<exp>/debug/`.
   - Fold loop: train, save the model natively under `model/fold{k}.*`, fill OOF, log the fold score.
   - `score_folds` over validated rows, `write_oof`, `write_metrics` immediately.
7. `if __name__ == "__main__": main(tyro.cli(Config))`.

## Artifacts in output/<exp>/<run>/

| File | Written by | Contents |
|---|---|---|
| `config.json` | start of run | resolved `Config` and `argv` |
| `run.log` | throughout | console log copy |
| `model/fold{k}.*` | fold loop | native model files |
| `oof.parquet` | end of run | id, target, fold, pred for validated rows |
| `metrics.json` | end of run | see schema |
| `submission.csv` | `just infer` | the file `just submit` validates |

## metrics.json schema

```json
{
  "exp": "exp013_target_enc", "base": "exp012_lgbm_te", "run": "default",
  "cv": 0.8215, "cv_folds": [0.83, 0.81, 0.82, 0.83, 0.82], "metric": "accuracy",
  "config": {"...": "resolved Config"}, "argv": [],
  "git_commit": "40-hex", "started_at": "ISO", "finished_at": "ISO", "notes": ""
}
```

`kgl.io.Metrics` is the dataclass; `tools/exp_table.py` and `tools/issue_comment.py` read it.

## What makes an experiment comparable

Same fold file, same metric name, same data version. When any of these change, start a new table
(new fold name, note in `docs/validation.md`) rather than mixing rows.
