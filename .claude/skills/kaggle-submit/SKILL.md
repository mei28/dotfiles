---
name: kaggle-submit
description: Submit a Kaggle experiment from a waggle-based competition repository. Produces submission.csv with infer.py, checks rows, columns, id order, and missing values against the sample, then runs the printed kaggle submit command for CSV competitions, or updates the codes and model Datasets, pushes the thin marimo notebook kernel, and submits its output for code competitions. Records the LB in docs/submissions.md and the Issue. Use when the user says 提出, submit, サブミット, or asks for the LB score.
---

# kaggle-submit

Turn a finished run into a scored submission without spending a submission slot by accident. The
default stops after validation and prints the final command; `--now` goes through to the LB and the
record. Commands come from the template's `justfile` (`just --list`); the flow is decided here.

## When to use

- A run has `metrics.json` and the user wants it on the leaderboard.
- The user asks for the LB score of a pending submission.
- Not for deciding whether a CV is trustworthy: `kaggle-validation` first, then submit.

## Preconditions

- `output/<exp>/<run>/metrics.json` exists and the run used the current fold file.
- `kaggle competitions submission-limits -c <comp>` shows a remaining slot for today.
- For a new model family: a `leak-reviewer` report under `docs/reviews/` with no open `high` item.
- Kaggle CLI login works (`kaggle competitions submissions -c <comp>` lists submissions).

## Steps for a CSV competition (`SUBMIT_MODE=csv`)

1. `just infer <exp> [--run <run>]` writes `output/<exp>/<run>/submission.csv` through the same
   `infer.py` a kernel would run.
2. `just submit <exp> "<message>" [--run <run>]` validates against the sample (rows, columns, id
   order, nulls) and prints the exact `kaggle competitions submit` command. Stop and show it to the
   user unless they asked to submit in one go.
3. `just submit <exp> "<message>" --now` submits, waits for scoring, and appends the row to
   `docs/submissions.md` (date, exp, run, cv, public LB, message).
4. `just record <exp> <issue> --run <run> --lb <score>` adds the LB to the Issue comment, and the
   CV vs LB table in `docs/validation.md` gets its row (see `kaggle-validation`).

## Steps for a code competition (`SUBMIT_MODE=code`)

The kernel is a thin wrapper that runs `infer.py` from a codes Dataset against a model Dataset; the
four assets and their versions are described in `references/code-competition-assets.md`.

1. `just infer <exp>` locally first. If it fails here it fails in the kernel.
2. `just upload-model <exp> [--run <run>]` versions `<user>/<comp>-<exp>-model` from `output/<exp>/<run>/`
   (`model/`, `config.json`, `metrics.json`).
3. `just upload-codes <exp>` versions `<user>/<comp>-codes` from `src/kgl`, `experiments/<exp>`, and
   `pyproject.toml`. Wait for `kaggle datasets status` to report ready before the next step.
4. `just push-kernel <exp>` renders `sub/sub.py` from the marimo template, exports it to `sub.ipynb`,
   writes `kernel-metadata.json` (title under 50 characters, `enable_internet: false`, the two
   Datasets as sources), pushes it, and saves the kernel version.
5. `just kernel-status` until the run completes; `kaggle kernels logs <user>/<comp>-sub` on failure
   (`references/submission-troubleshooting.md`). Download the output with `kaggle kernels output` and
   diff `submission.csv` against the local one when in doubt.
6. `just submit <exp> "<message>" --now --kernel <user>/<comp>-sub --version <n>` submits the kernel
   output and records the LB as in the CSV flow.

## Notes

- Messages carry `exp/run cv=` automatically; add what changed in the free text.
- Two final submissions are chosen by CV, not by public LB, unless the CV vs LB table shows the split
  is broken.
- The kernel imports only what the Kaggle image provides plus `kgl`; when a dependency is missing,
  add wheels as a Dataset and install them offline in the notebook (assets reference).
- A submission that errors on Kaggle still consumes a slot in some competitions; read the logs
  before retrying.

## Mistakes

- Submitted without `validate_submission`; the id order was the test file's, not the sample's.
- Pushed the kernel before the codes Dataset finished processing; it ran the previous version.
- Chose the final pair by public LB after the CV vs LB table had shown the LB was noise.
- Reran `--now` on a failed submission without reading `kaggle kernels logs`.
- Forgot the daily limit and burned the last slot on a debug run.

## Related skills

- `kaggle-validation`: CV vs LB table and leak review.
- `kaggle-experiment`: the run being submitted.

## Sources

- ho.lc, "効率的なコードコンペティションの作業フロー" <https://ho.lc/blog/kaggle-code-submission>
- upura, "コードコンペティション" wiki page
  <https://github.com/upura/everyday-kaggle-news/blob/main/docs/wiki/concepts/code-competition.md>
- osushinekotan, "code competition も楽したい KaggleOps"
  <https://osushinekotan.hatenablog.com/entry/2025/12/06/072458>
- sugupoko, submit-check rules in kaggle_starterRepository <https://github.com/sugupoko/xxxx_kaggle_starterRepository>
- Kaggle CLI, kernels metadata reference <https://github.com/Kaggle/kaggle-cli/blob/main/docs/kernels_metadata.md>
