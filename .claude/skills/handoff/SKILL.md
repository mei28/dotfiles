---
name: handoff
description: Write or update `.tmp/progress.md` (Goal/Plan/Done/Next/Open/Resume) so work can be resumed later, by a new Claude Code session or, when the user switches tools, by Codex / Antigravity / opencode. Use when the user asks for a handoff or to pause work.
---

# handoff

Create the handoff note that lets the next session pick up seamlessly. See `~/dotfiles/docs/claude-codex.md`.

## When to use
- The user asks to pause, hand off, or wrap up work that a later session will continue.
- The user is switching to another tool (Codex, Antigravity, opencode) and wants it to resume from here.

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

## Next session
- In Claude Code: start the session by reading `.tmp/progress.md`.
- In Codex: paste the note or ask it to read `.tmp/progress.md`. The custom `/resume` prompt is
  shadowed by Codex's built-in session picker on codex 0.142.3 (see `codex-implement`).
- In Antigravity / opencode: ask it to read `.tmp/progress.md`.
