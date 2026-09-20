# Submission troubleshooting

Read `kaggle kernels logs <user>/<comp>-sub` first; the message usually names the cause.

| Symptom | Cause | Fix |
|---|---|---|
| `ModuleNotFoundError: kgl` | `PYTHONPATH` not set to the codes Dataset's `src`, or the Dataset attached is an old version | Re-render with `just push-kernel`; wait for `datasets status` before pushing |
| `ModuleNotFoundError: <package>` | Package not in the Kaggle image | Add wheels to the deps Dataset; or remove the import from `infer.py` |
| `FileNotFoundError: no fold models under ...` | Model Dataset missing or path differs | `just upload-model <exp>`; check `dataset_sources` and the `--model-dir` argument |
| `competition data not found: /kaggle/input/<comp>` | `competition_sources` missing, or the slug differs from `Config.comp` | Fix `kernel-metadata.json` and `Config.comp` |
| 400 on `kernels push` | Title longer than 50 characters, or slug and title disagree | Shorten the title; keep `id` and `title` consistent |
| Kernel exceeds the time limit | Inference too slow for the hidden test size | Batch predictions; fewer fold models; measure locally on a test-sized sample |
| GPU OOM | Batch size or model too large for the T4 | Reduce batch size; `enable_gpu` with `machine_shape` if the competition allows |
| `AssertionError: id order differs from the sample` | Predictions joined in a different order | Build the submission from the sample frame and replace the prediction column |
| Submission scored 0 or NaN | Wrong dtype or clipped range | Match the sample dtype (`pl.Series(..., dtype=sample[col].dtype)`); clip probabilities |
| `competitions submit` rejected for a code competition | `-f` used instead of `-k`/`-v`, or the version has not finished running | Wait for `kernels status` complete; pass `--kernel` and `--version` |
| Submission status `ERROR` with no logs | Kaggle-side failure | Wait, then retry once; if it persists, check the discussion forum for outages |
