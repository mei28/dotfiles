# Code competition assets

A code competition scores a notebook that runs with internet off inside a time limit. The template
splits what the notebook needs into four assets so that each changes for one reason.

| Asset | Kaggle type | Name | Contents | New version when |
|---|---|---|---|---|
| codes | Dataset | `<user>/<comp>-codes` | `src/kgl/`, `experiments/<exp>/`, `pyproject.toml` | code changed (`just upload-codes <exp>`) |
| model | Dataset | `<user>/<comp>-<exp>-model` | `model/`, `config.json`, `metrics.json` of one run | the run changed (`just upload-model <exp>`) |
| deps | Dataset | `<user>/<comp>-deps` | wheels for packages the Kaggle image lacks | a dependency was added |
| submission | Kernel (notebook) | `<user>/<comp>-sub` | thin wrapper: install deps offline, run `infer.py`, show the output | rarely; `just push-kernel` re-renders it |

## The wrapper notebook

`sub/sub.template.py` is a marimo notebook without `mo.ui`. `just push-kernel <exp>` fills the
placeholders (codes and model Dataset paths, experiment name, deps), exports it with
`marimo export ipynb --sort top-down`, and pushes `sub/`. The cells are:

1. Constants: `CODES = "/kaggle/input/<comp>-codes"`, `MODEL = "/kaggle/input/<comp>-<exp>-model"`.
2. Optional `pip install --no-index --no-deps /kaggle/input/<comp>-deps/*.whl`.
3. `subprocess.run([sys.executable, f"{CODES}/experiments/<exp>/infer.py", "--model-dir", f"{MODEL}/model"],
   env={**os.environ, "PYTHONPATH": f"{CODES}/src"}, check=True)`.
4. Read `/kaggle/working/submission.csv` and print shape and head.

`infer.py` detects the Kaggle environment (`KAGGLE_KERNEL_RUN_TYPE`), reads the competition data from
`/kaggle/input/<comp>`, and writes `/kaggle/working/submission.csv`. The same file writes
`output/<exp>/<run>/submission.csv` locally.

## kernel-metadata.json

```json
{
  "id": "<user>/<comp>-sub", "title": "<comp>-sub",
  "code_file": "sub.ipynb", "language": "python", "kernel_type": "notebook",
  "is_private": true, "enable_gpu": false, "enable_tpu": false, "enable_internet": false,
  "dataset_sources": ["<user>/<comp>-codes", "<user>/<comp>-<exp>-model"],
  "competition_sources": ["<comp>"], "kernel_sources": [], "model_sources": []
}
```

Titles are limited to 50 characters; `enable_gpu` only when inference needs it (it costs quota).

## Dependencies the image lacks

Build wheels on a machine with internet for the image's Python (3.12, manylinux):
`pip download --only-binary=:all: --python-version 3.12 --platform manylinux2014_x86_64 -d wheels/ <pkg>`,
upload `wheels/` as `<user>/<comp>-deps`, and let the notebook install them with `--no-index`. Prefer
avoiding the dependency: `infer.py` should need only numpy, polars, the model library, and `kgl`.

## Versions and waiting

`kaggle datasets version` returns before processing finishes. Poll `kaggle datasets status <user>/<slug>`
until it is ready before pushing the kernel, or the kernel attaches the previous version. Kernel
pushes print `Kernel version N`; that `N` is what `kaggle competitions submit -k <user>/<comp>-sub -v N`
needs.
