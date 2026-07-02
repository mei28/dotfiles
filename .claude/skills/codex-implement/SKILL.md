---
name: codex-implement
description: Delegate implementation of an approved plan to OpenAI Codex via `codex exec`, the Codex TUI, or a final-only MCP call, then summarize the resulting diff. Use after planning in Claude Code, to offload heavy implementation to Codex and conserve Claude's budget.
---

# codex-implement

Hand implementation work to Codex while Claude Code stays the planner/orchestrator.
See `docs/claude-codex.md` for the full workflow.

## When to use
- A plan is ready (Plan mode output, a plan file, or `$ARGUMENTS`) and the change should be implemented by Codex.
- You want to spend Codex's budget on implementation instead of Claude's.

## Steps
1. Check that Codex is available:
   ```bash
   command -v codex
   ```
   If not found, stop and report: "Codex is not installed on this machine. Install via nix (`just build <host>`) or run `/antigravity-implement` as an alternative."
2. Identify the task source, in this order: `$ARGUMENTS` → the approved plan file → the newest `.tmp/plan*.md`. If none exists, ask the user what to implement.
3. Make sure `.tmp/progress.md` reflects the current Goal/Plan (run the `handoff` skill first if it is stale).
4. Choose the delegation lane:

   **Lane A — Autonomous (background)**: Use when the full plan content can be embedded directly in the prompt and no interactive approval is needed. Read the plan file with Claude's Read tool first, then pass its content inline so Codex never needs to call MCP Read itself — that call fails in a no-TTY background process.
   ```bash
   codex exec -p shared -c approval_policy=never --json -o .tmp/codex-implement.jsonl \
     "<full plan content here>. Follow the standards in ~/.codex/AGENTS.md. Keep changes focused; do not commit."
   ```
   Run with `run_in_background`. Use `codex exec resume --last` to inspect a finished run.

   **Lane B — Supervised TUI**: Use when the task is complex, approval is needed, or Lane A keeps failing. Present this exact block to the user as copy-paste for a **separate terminal pane**:

   ```
   別ペインで以下を実行してください:

   codex -p shared -a on-request

   起動後: /resume
   完了後: /handoff
   ```

   When Codex finishes and runs `/handoff`, `.tmp/progress.md` is updated — Claude reads it to continue.

   **Lane C — Final-only MCP**: Use only for short, self-contained tasks where no progress stream is needed. Use the MCP `codex` tool with `approval-policy: never`.

5. When Codex finishes, run `git diff` (and `git status`) and summarize what changed, file by file.
6. Update `.tmp/progress.md` (Done/Next/Open). Flag anything that needs review with `codex-review` or Claude's `/code-review`.

## Notes
- **Lane A failure mode**: `codex exec` in background spawns `claude mcp serve` as a subprocess. Without a TTY, MCP tool calls (Read, Bash, Edit) are auto-cancelled with "user cancelled MCP tool call". Fix: embed all needed content in the prompt; do not ask Codex to read files via MCP.
- MCP `codex` human approval is currently unusable because Codex issue #18268 makes compliant approval responses fall back to Denied. Use TUI (Lane B) for human approval.
- Orchestrating Codex from Claude still consumes Claude tokens. If Claude is near its limit, do not use this skill; tell the user to run `codex -p shared` directly and `/resume` from `.tmp/progress.md`.
- Codex edits files itself; do not also edit them from Claude in parallel.
