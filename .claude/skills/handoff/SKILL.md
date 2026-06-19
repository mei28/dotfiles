---
name: handoff
description: Write or update `.tmp/progress.md` so work can be resumed by the other AI tool (Claude Code <-> Codex), typically before switching tools when one nears its usage limit. Captures Goal/Plan/Done/Next/Open/Resume.
---

# handoff

Create the handoff note that lets the other tool pick up seamlessly. See `docs/claude-codex.md`.

## When to use
- About to switch from Claude Code to Codex (or back) — e.g. a usage limit is near.
- Pausing work that the other tool will continue.

## Steps
1. Gather the current state from the conversation and the repo (`git status`, `git diff --stat`).
2. Write `.tmp/progress.md` with exactly this structure:
   ```
   # Goal:   <what we are achieving>
   # Plan:   <path to plan file, or bullet plan>
   # Done:   <changes already made, with key file paths>
   # Next:   <immediate next steps, ordered>
   # Open:   <unresolved questions / decisions needed>
   # Resume: <files/commands the next tool should read or run first>
   ```
3. Be specific: real file paths and commands, not vague summaries. Put must-read-first items under `Resume:`.
4. Do not change source code in this step. After writing, print the path and a one-line status.

## Next tool
- In Codex: run `/resume` (reads `.tmp/progress.md` and continues).
- In Claude Code: start the session by reading `.tmp/progress.md`.
