---
name: antigravity-implement
description: Delegate implementation of an approved plan to Antigravity CLI (agy) via `agy --headless --approve all`, then summarize the resulting diff. Use as an alternative to codex-implement when Codex is unavailable or at its limit.
---

# antigravity-implement

Hand implementation work to Antigravity CLI while Claude Code stays the orchestrator/evaluator.
See `docs/antigravity.md` for the full workflow.

## When to use
- A plan is ready and Codex is unavailable or near its limit.
- You want a different model to implement to get a fresh perspective.
- `$ARGUMENTS` contains the task or plan file path.

## Prerequisites

Antigravity CLI must be installed and authenticated:
```bash
# Install
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Authenticate (first time — opens browser for Google auth)
agy
```

## Steps

1. Check that Antigravity CLI is available:
   ```bash
   command -v agy
   ```
   If not found, stop and report: "Antigravity CLI (`agy`) is not installed on this machine. Install with: `curl -fsSL https://antigravity.google/cli/install.sh | bash`. Alternatively run `/codex-implement` if Codex is available."
2. Identify the task source, in this order: `$ARGUMENTS` → the approved plan file → the newest `.tmp/plan*.md`. If none exists, ask the user what to implement.
3. Ensure `.tmp/progress.md` is current (run the `handoff` skill first if stale).
4. Run Antigravity non-interactively with `--headless --approve all` (auto-accepts file edits) using `run_in_background`:
   ```bash
   agy --headless --approve all -p "Implement the plan in <plan-file>. Follow the standards in .claude/AGENTS.md. Keep changes focused; do not commit.

   Plan:
   $(cat <plan-file>)"
   ```
   Antigravity writes files directly. Monitor terminal output for progress.
   Note: even in headless mode, Antigravity applies OS-level sandbox protection (macOS: `sandbox-exec`).
5. When Antigravity finishes, run `git diff` (and `git status`) and evaluate the result:
   - Correctness: does it match the plan?
   - Standards: does it follow `.claude/AGENTS.md`?
   - Quality: any obvious issues?
6. Accept the changes, request fixes, or revert (`git checkout -- .`) if the output is unacceptable.
7. Update `.tmp/progress.md` (Done/Next/Open). Flag anything that needs follow-up review with `/antigravity-review` or `/code-review`.

## Notes

- `--headless --approve all` auto-accepts all tool calls (file writes, shell commands). Confirm the plan is sound before using this flag.
- Antigravity does not have a built-in `--json` progress stream like Codex's `codex exec --json`. Use `run_in_background` and check terminal output when it completes.
- Antigravity edits files itself; do not also edit them from Claude in parallel.
- If Codex is available and the task is complex, prefer `/codex-implement` — Codex has a more mature autonomous implementation workflow in this setup.
- herdrによる監督レーン自動化(`codex-implement`のherdr連携を参照)はAntigravityには未対応。herdrの公式エージェント検出一覧に`agy`は含まれず、`agent_status`検出の精度が未検証のため、当面は本skillを従来どおり手動運用のまま据え置く。
