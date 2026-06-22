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
   - Default autonomous lane for approved implementation: run Codex non-interactively with `run_in_background`, and start a Monitor for the JSON stream:
     ```bash
     codex exec -p shared -c approval_policy=never --json -o .tmp/codex-implement.jsonl "Implement the plan in <plan-file>. Follow the standards in ~/.codex/AGENTS.md. Keep changes focused; do not commit."
     ```
     Use `codex exec resume --last` for follow-up inspection of the latest non-interactive run.
   - Supervised or approval-required lane: do not use MCP. Present this copy-paste command to the user for a separate pane:
     ```bash
     codex -p shared -a on-request
     # then run: /resume
     ```
     When Codex returns work to Claude, ask it to run `/handoff` so `.tmp/progress.md` is current.
   - Final-only short lane: use the MCP `codex` tool only with `approval-policy: never` when no progress stream and no human approval are needed.
5. When Codex finishes, run `git diff` (and `git status`) and summarize what changed, file by file.
6. Update `.tmp/progress.md` (Done/Next/Open). Flag anything that needs review with `codex-review` or Claude's `/code-review`.

## Notes
- MCP `codex` human approval is currently unusable because Codex issue #18268 makes compliant approval responses fall back to Denied. Use TUI for human approval.
- MCP returns final-only output with no progress stream. Prefer `codex exec --json` with `run_in_background` + Monitor for autonomous implementation.
- Orchestrating Codex from Claude still consumes Claude tokens. If Claude is near its limit, do not use this skill; run `codex -p shared` directly in another pane and `/resume` from `.tmp/progress.md`.
- Codex edits files itself; do not also edit them from Claude in parallel.
