---
name: codex-implement
description: Delegate implementation of an approved plan to OpenAI Codex (via the codex MCP tool or `codex exec --profile implement`), then summarize the resulting diff. Use after planning in Claude Code, to offload heavy implementation to Codex and conserve Claude's budget.
---

# codex-implement

Hand implementation work to Codex while Claude Code stays as the planner/orchestrator.
See `docs/claude-codex.md` for the full workflow.

## When to use
- A plan is ready (Plan mode output, a plan file, or `$ARGUMENTS`) and the change should be implemented by Codex.
- You want to spend Codex's budget on implementation instead of Claude's.

## Steps
1. Identify the task source, in this order: `$ARGUMENTS` → the approved plan file → the newest `.tmp/plan*.md`. If none exists, ask the user what to implement.
2. Make sure `.tmp/progress.md` reflects the current Goal/Plan (run the `handoff` skill first if it is stale).
3. Delegate to Codex:
   - If the `codex` MCP server is connected, call its tool with a prompt that references the plan file and tells it to implement following `~/.codex/AGENTS.md`.
   - Otherwise run Codex non-interactively (sandbox flag grants write access; no profile needed):
     ```bash
     codex exec -s workspace-write -c model_reasoning_effort=high "Implement the plan in <plan-file>. Follow the standards in ~/.codex/AGENTS.md. Keep changes focused; do not commit."
     ```
     For long tasks start it with `run_in_background` and watch with Monitor until it exits.
4. When Codex finishes, run `git diff` (and `git status`) and summarize what changed, file by file.
5. Update `.tmp/progress.md` (Done/Next/Open). Flag anything that needs review with `codex-review` or Claude's `/code-review`.

## Notes
- Orchestrating Codex from Claude still consumes Claude tokens. If Claude is near its limit, do NOT use this skill — run `codex` directly in another pane and `/resume` from `.tmp/progress.md`.
- Codex edits files itself; do not also edit them from Claude in parallel.
