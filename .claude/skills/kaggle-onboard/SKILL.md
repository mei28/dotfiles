---
name: kaggle-onboard
description: Start a Kaggle competition from the waggle template repository. Creates the repo under ~/kaggle, fills docs/competition.md (task, data, metric, submission format, timeline, rules), decides CSV versus code submission, adds the metric to kgl.metrics with a test, downloads the data, researches top solutions with the nvidia-kaggle plugin, and opens the first Issues. Use when the user says 新しいコンペ, コンペを始める, onboard, or shares a competition URL to join.
---

# kaggle-onboard

Set up one competition repository from <https://github.com/mei28/waggle> and write down
what the competition is before any model code exists. Commands live in the template's `justfile`
(`just --list`); this skill decides the order and what must be true before moving on.

## When to use

- The user names a competition to join or pastes its URL.
- A competition repository exists but `docs/competition.md` is still the template skeleton.
- Not for adding an experiment to a running competition: `kaggle-experiment`.

## Prerequisites

Run `~/.claude/skills/kaggle-onboard/scripts/check-prereqs.sh` from the competition repository right
after step 1 (`just setup` writes `KAGGLE_API_TOKEN` into `.env`, and the check reads it from there or
from the environment). It checks the Kaggle CLI login, `gh auth status`, the `nvidia-kaggle` plugin,
and the token. When something is missing, report the command the script prints and stop; do not work
around it. The user must have joined the competition on Kaggle (accepted the rules) before
`just download` works.

## Steps

1. Create the repository and the labels:
   `cd ~/kaggle && gh repo create <comp> --template mei28/waggle --private --clone`,
   then `cd <comp> && just setup && just labels`. Set `COMP=<slug>` in `.env`, then run the
   prerequisites check above.
2. Fetch the competition context with the `nvidia-kaggle` skill (competition details and dataset
   description workflows) and `kaggle competitions submission-limits -c <comp>`. Fill every section of
   `docs/competition.md` using `references/competition-checklist.md`. Compute the 30% and 70% dates
   from start and deadline; the phase guard in the repo's `CLAUDE.md` reads them.
3. Decide the submission mode from the rules text. "Submissions are made from Kaggle Notebooks",
   an internet-off requirement, or a runtime limit means a code competition: set `SUBMIT_MODE=code`
   in `.env` and record runtime, GPU, and dependency limits. Otherwise `SUBMIT_MODE=csv`.
4. `just download <comp>`. Note the file names, the sample submission file, the id column, and the
   target column, then set them in `experiments/exp000_baseline/run.py` (`Config` defaults: `comp`,
   `target`, `id_col`, `train_file`, `test_file`, `sample_sub`, `metric`).
5. Pin the metric. Copy the official definition into `docs/competition.md` (averaging, thresholds,
   ties). If `kgl.metrics` lacks it, add it through the `tdd` skill with a hand-computed test in
   `tests/test_metrics.py`, and set `Config.metric`.
6. Research prior art with the `nvidia-kaggle` skill: top leaderboard writeups (for a finished
   competition or a similar past one), discussions searched for "CV", "validation", "leak", and
   "shift", and the most voted public kernels. Write one page under "Prior art" with links and the
   one-line takeaway of each; the takeaways become Issue candidates.
7. Propose the first Issues and stop for approval: one `cv` Issue (how the test set was built and
   which split to use), one `idea` Issue for the baseline, and three to five `idea` Issues from prior
   art. After approval create them with `gh issue create --label <label> --title <title> --body <body>`
   using the headings of `.github/ISSUE_TEMPLATE/idea.yml` (Hypothesis, Why it might work, How to
   test, Expected effect).
8. Hand off: fold design goes through `kaggle-validation`; the baseline run goes through
   `kaggle-experiment`. Say so and stop.

## Notes

- Run the plugin's scripts with the competition repository as the working directory (`uv run --with
  httpx --with pydantic --with python-dotenv --with rich python <plugin>/scripts/<name>.py ...`). They
  look for the nearest `pyproject.toml` to find `.env`; run from the plugin directory they would read
  the plugin's own `pyproject.toml` instead. The plugin lives under
  `~/.claude/plugins/cache/nvidia-kaggle/`.
- `input/<comp>/` mirrors `/kaggle/input/<comp>/`, so paths in code stay the same in the kernel.
- The 30% and 70% dates decide which requests count as phase violations later. Write them even when
  the deadline is far away.
- Keep `docs/competition.md` to facts from the competition pages. Interpretations go to Issues.
- For simulation competitions (agents that play against each other) the checklist adds the engine,
  the agent interface, and the per-move limits; see the last section of the checklist reference.

## Mistakes

- Started writing model code before the seven checklist items were filled.
- Guessed the metric's averaging or the id order instead of reading the evaluation page.
- Created Issues without approval, or one Issue per experiment instead of one per idea.
- Skipped `just labels`; template repositories do not copy labels.
- Searched writeups by hand when the plugin was installed, or built a fallback path when it was not.

## Related skills

- `kaggle-validation`: fold design after onboarding.
- `kaggle-experiment`: the first baseline run.
- `tdd`: adding the metric to `kgl.metrics`.

## Sources

- upura, "everyday-kaggle-news" wiki, mindset and code-competition pages
  <https://github.com/upura/everyday-kaggle-news/tree/main/docs/wiki/concepts>
- sugupoko, competition onboarding checklist in kaggle_starterRepository
  <https://github.com/sugupoko/xxxx_kaggle_starterRepository>
- NVIDIA, nvidia-kaggle plugin <https://github.com/NVIDIA/nvidia-kaggle>
