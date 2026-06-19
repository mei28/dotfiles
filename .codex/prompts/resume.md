Resume work handed off from another AI tool (usually Claude Code).

Steps:
1. Read `.tmp/progress.md` in the repo root. It uses this format: Goal / Plan / Done / Next / Open / Resume.
2. Read every file listed under `Resume:` (plan file, key sources). Do not start before reading them.
3. Re-state in one or two lines: the Goal, what is already Done, and your immediate Next step.
4. Continue from `Next:`. Follow the shared standards in `~/.codex/AGENTS.md` (and any repo `AGENTS.md`/`CLAUDE.md`).
5. As you make progress, keep `.tmp/progress.md` up to date so the work can be handed back.

If `.tmp/progress.md` is missing, ask what to resume instead of guessing.
