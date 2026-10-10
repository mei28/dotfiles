---
name: kaggle-research
description: Check a Kaggle competition's forum and public notebooks for what changed and merge it into docs/discussions.md and docs/notebooks.md of a waggle-based competition repository. Offers itself at the start of work with the date of the last check (the SessionStart hook prints it), fetches threads and kernels with the nvidia-kaggle plugin, merges findings into topic sections instead of dated ones, copies host rulings into docs/competition.md, and hands the dated diff to the diary through kaggle-journal. Use when the user says discussion, ノートブック, 公開ノートブック, 情報収集, いつも通り調査, 新しい情報はあるか, or asks what the public kernels do or why they score higher.
---

# kaggle-research

The forum and the public kernels change every day, and some of what they say changes the plan: a
host ruling, a measured trick, a kernel that scores above ours. This skill reads what is new since the
last check and folds it into two docs that hold what is known now, by topic. When something changed
is the diary's job, not the docs'.

## When to use

- Start of a work session. The SessionStart hook prints
  `docs/discussions.md last checked: <date>`. When the date is not today, ask once: "the last check
  was <date> (N days ago); check the forum and notebooks?" Run on yes; on no, do not ask again in this
  session.
- The user asks for the forum, the public notebooks, their scores, or the gap to them.
- Not for the onboarding pass: `kaggle-onboard` step 6 does the first check, in the same formats.

## Steps

1. Read what is already known: the `<!-- last-checked: ... -->` marker, "Read first", "Host
   answers", and "Open questions" of `docs/discussions.md`, and "Lineage" of `docs/notebooks.md`.
2. Fetch what is new since the marker date. Run the plugin scripts from the competition repository
   (see `kaggle-onboard` notes).
   - Threads new or updated since then, with their comments: the `nvidia-kaggle` discussion workflow.
   - Kernels: `uv run kaggle kernels list --competition <comp> --sort-by dateCreated -v` and
     `--sort-by voteCount`, the public score per ref (`fetch_kernel_score.py <ref>`), and the source
     of new or updated kernels with `kaggle kernels pull -m <ref> -p .tmp/kernels/<owner>__<slug>/`.
   - When a script fails or returns far less than the site shows, look up the symptom in
     `references/plugin-workarounds.md`. Apply a workaround only when its symptom appears.
3. Read in this order: host answers (they change the rules), threads with measurements, kernels that
   score above ours or use a method we lack. Team hunting and chatter go under "Skip" by id only.
4. Merge into the docs (`references/digest-format.md`). Edit the topic sections; never add a section
   per date. Host answers get one dated line each, and rulings are copied into the rules section of
   `docs/competition.md`. Update the marker and the counts line.
5. Report in chat what changes the plan, with thread ids, kernel refs, and numbers. A new idea is a
   proposal; it becomes an `idea` Issue only after the user agrees.
6. A finished check is a wrap-up checkpoint: offer the `kaggle-journal` wrap-up. The diary comment
   gets the "調査の差分" section with the dated diff (new threads, host answers, kernels and scores).

## Notes

- Source `.env` for `KAGGLE_API_TOKEN` and never print it. On a 401 from the plugin, run
  `just kaggle-token` first; the token lasts a few hours.
- A score in a kernel's title or text is self-reported. Write it as unverified until the public score
  comes from the API.
- Before adopting code, data, or weights from a kernel, record its license under "Licenses and
  shared datasets".
- Converting an existing dated digest to topic sections is its own commit, before the commit with
  the new findings.

## Mistakes

- Appended the findings under a date heading; the digest doubled in size every week, and each check
  re-read all of it.
- Wrote a host ruling into the digest but not into `docs/competition.md`, so the rules section went
  stale.
- Created `idea` Issues from forum ideas without asking.
- Patched around a plugin failure that had not happened.
- Trusted a kernel's title score and chased a gap that did not exist.
- Printed the Kaggle token while debugging a 401.

## Related skills

- `kaggle-journal`: the wrap-up that carries the dated diff into the diary.
- `kaggle-onboard`: the first check at the start of the competition.
- `nvidia-kaggle:nvidia-kaggle-skill`: the fetch and read workflows.

## Sources

- `docs/discussions.md` and `docs/notebooks.md` of mei28/enveda-casmi26, checked ten times between
  2026-09-21 and 2026-10-10 on the user's "いつも通り discussion と code を確認して".
