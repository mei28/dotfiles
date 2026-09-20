# Training in a Kaggle Notebook

Use the free T4x2 hours when the local GPU is too small. The same `run.py` runs in the kernel; only
the launch and the artifact retrieval differ. Check `kaggle quota` first.

## One-time setup

1. Upload the code as a Dataset: `just upload-codes <exp>` stages `src/kgl`, `experiments/<exp>`, and
   `pyproject.toml` and creates or versions `<user>/<comp>-codes` (see the `kaggle-submit` skill's
   asset reference for naming).
2. Create a training kernel folder, for example `kernels/train/`, with `kaggle kernels init -p kernels/train`
   and edit `kernel-metadata.json`:
   ```json
   {
     "id": "<user>/<comp>-train", "title": "<comp>-train",
     "code_file": "train.py", "language": "python", "kernel_type": "script",
     "is_private": true, "enable_gpu": true, "enable_internet": false,
     "dataset_sources": ["<user>/<comp>-codes"], "competition_sources": ["<comp>"]
   }
   ```
   `train.py` is a few lines: set `PYTHONPATH` to the codes Dataset's `src`, then run
   `experiments/<exp>/run.py` with the overrides you want. Titles are limited to 50 characters.

## Each training run

1. `just upload-codes <exp>` when code changed (wait for `kaggle datasets status` to report ready).
2. `kaggle kernels push -p kernels/train --accelerator NvidiaTeslaT4` (see `kaggle kernels push --help`
   for the accelerator names; `--timeout` caps the run).
3. `kaggle kernels status <user>/<comp>-train` until `complete`; `kaggle kernels logs <user>/<comp>-train`
   when it fails.
4. Pull the artifacts: `kaggle kernels output <user>/<comp>-train -p output/<exp>/<run>/`. The kernel
   writes to `/kaggle/working`, which is what `kernels output` downloads; `run.py` on Kaggle writes
   `metrics.json`, `oof.parquet`, and `model/` under `/kaggle/working/<exp>/<run>/`, so move them into
   place if the paths differ, then `just exp-table` and `just record` as for a local run.

## Constraints to remember

- Internet is off in competition kernels; dependencies beyond the image need wheels in a Dataset.
- `git_commit` is recorded as `kaggle` because the kernel has no repository; note the local commit in
  the Issue comment.
- Weekly GPU quota is shared with inference kernels for submissions; budget it.
