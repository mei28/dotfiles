---
name: kaggle-experiment
description: Create, run, and record one experiment in a waggle-based competition repository. Copies expNNN_change from a base with the hypothesis written first, configures it through the Config dataclass and tyro overrides, runs debug then full, and writes metrics.json, oof.parquet, docs/experiments.md, and the Issue comment right after training. Use when the user asks for a new experiment, a rerun, a variant, or to record results, or says 実験, 回して, ベースライン, 記録して.
---

# kaggle-experiment

One experiment is one directory under `experiments/`, one hypothesis, and one set of artifacts under
`output/<exp>/<run>/`. This skill runs that loop and keeps the record complete. Commands come from the
template's `justfile` (`just --list`); the repo's `CLAUDE.md` holds the always-on rules (phase guard,
output-first error analysis, decision gates).

## When to use

- The user wants a new experiment, a variant of an existing one, or a rerun.
- A run finished and its result must be recorded.
- Not for choosing the fold design (`kaggle-validation`) or for submitting (`kaggle-submit`).

## Steps

0. Orient. Read the tail of `docs/experiments.md`, the open `idea` Issues (`gh issue list --label idea`),
   and the phase from `docs/competition.md`. If the request belongs to a later phase, say so and let
   the user decide.
1. Write the hypothesis before code: one sentence in the Issue (create one with the `idea` template
   when none fits) and in the `run.py` docstring (`hypothesis:` line, `issue: #N`).
2. Create the directory from the closest base: `just new-exp exp013_change exp012_base`. The tool
   rewrites the docstring header and `base:`; keep `base:` truthful when copying by hand.
3. Change only what the hypothesis needs. Tunables go into `Config` (nested dataclasses for groups
   such as `model_params`), named components go through `kgl.registry`. Code that a second
   experiment will need moves into `src/kgl` with a test (`tdd` skill); until then it stays in `run.py`.
   Read `references/experiment-anatomy.md` for what each part of `run.py` must do.
4. Debug run first: `just run <exp> --debug` (first fold, small subset, artifacts under
   `output/<exp>/debug/`). Fix anything it reveals before the full run.
5. Full run: `just run <exp>`. Runs longer than a minute go to the background (Claude Code:
   `run_in_background`; other runtimes: `nohup ... &` or a second terminal). Variants are CLI
   overrides, for example
   `just run <exp> --model-params.n-estimators 500 --seed 1`; each distinct override set gets its own
   run directory named by a hash, or `--run <name>` to choose.
6. Record right after the run finishes, without waiting to be asked: `just exp-table`, then
   `just record <exp> <issue> [--run <run>]`. Confirm `output/<exp>/<run>/metrics.json` exists; a run
   without it is not finished.
7. Look at the outputs before proposing anything: at least 20 worst and borderline OOF rows from
   `oof.parquet`, grouped by error type. Method in `references/error-analysis.md`. Write the groups
   into the Issue comment.
8. Propose two or three next steps as options with the expected effect and cost, tied to the error
   groups. The user picks; do not start the next experiment on your own unless told to continue.

## Kaggle Notebook training

When the local GPU is too small, run the same `run.py` in a Kaggle kernel and pull the artifacts back.
The procedure (codes Dataset, training kernel metadata, `kaggle kernels push --accelerator`,
`kernels status`, `kernels output`) is in `references/kaggle-notebook-training.md`. Check
`kaggle quota` before pushing.

## Notes

- Run ids: no overrides `default`, `--debug` `debug`, otherwise the first 8 hex chars of the sha1
  of the overrides. Rerunning the same overrides overwrites the same directory; that is intended, the
  code version is recorded as `git_commit` in `metrics.json`.
- Model files use the library's native format (`Booster.save_model`), never pickle, so the Kaggle
  image can load them across versions.
- `infer.py` imports only what the Kaggle image provides plus `kgl` and `run.py`. Keep CLI helpers
  (tyro) and trackers out of it.
- Seeds: `Config.seed` feeds `seed_everything` and the model; seed averaging is a late-phase idea, not
  a default.
- Trackers (`Config.tracker`: `none`, `wandb`, `mlflow`) are for curves. `metrics.json` is the record.

## Mistakes

- Started coding before the hypothesis was written, then reverse-engineered one to fit the result.
- Skipped the debug run and lost a full run to a shape error in the last fold.
- Changed two things at once, so the CV movement had no cause.
- Left a run without `metrics.json` or without the Issue comment because the user did not ask.
- Tuned hyperparameters from the score alone without opening the OOF rows.
- Copied shared code into a second experiment instead of moving it to `src/kgl` with a test.
- Compared runs that used different fold files as if they were one table.

## Related skills

- `kaggle-validation`: fold file and leak review before trusting a new model's CV.
- `kaggle-submit`: turning a run into a submission and recording LB.
- `tdd`, `tidy-first`: for code that moves into `src/kgl`.

## Sources

- upura, "実験管理" (experiment-management wiki page)
  <https://github.com/upura/everyday-kaggle-news/blob/main/docs/wiki/concepts/experiment-management.md>
- unonao, kaggle-template (major/minor versions, dataclass config) <https://github.com/unonao/kaggle-template>
- koukyo1994, "コンペ中のコード、どうしてる？" (one experiment, one script)
  <https://speakerdeck.com/koukyo1994/konpezhong-falsekodo-dousiteru>
- osushinekotan, ExpAgent experiment-workflow skill <https://github.com/osushinekotan/ExpAgent>
- sugupoko, output-first error analysis rule <https://github.com/sugupoko/xxxx_kaggle_starterRepository>
