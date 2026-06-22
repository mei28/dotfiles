---
name: antigravity-review
description: Get a second-opinion code review from Antigravity CLI (agy) on the current working-tree diff or branch, returning an APPROVED/WARNING/BLOCKED verdict. Use to cross-check Claude Code's own review with a different model.
---

# antigravity-review

Run a read-only Antigravity review of the current changes as a cross-check against Claude's `/code-review` and `/codex-review`.
See `docs/antigravity.md`.

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
   If not found, stop and report: "Antigravity CLI (`agy`) is not installed on this machine. Install with: `curl -fsSL https://antigravity.google/cli/install.sh | bash`. Alternatively run `/codex-review` if Codex is available."
2. Determine what to review: working-tree diff by default. Confirm the base branch (usually `main`). Use `$ARGUMENTS` to override scope (e.g. a specific file or commit range).
3. Build the diff and run Antigravity (read-only; do not use `--headless`):
   ```bash
   agy -p "You are doing a code review. For each issue give file:line, severity (critical/warning/info), problem description, and a suggested fix. Cover correctness, security, error handling, missing tests, and AGENTS.md standards (in .claude/AGENTS.md). End with one verdict: APPROVED / WARNING / BLOCKED.

   $(git diff HEAD)"
   ```
   - For a specific base branch: replace `HEAD` with `origin/main...HEAD`
   - For a specific file: append the file path after `git diff`
   - To leverage Antigravity's large context, include the full file alongside the diff:
     ```bash
     agy -p "Review this diff in context of the full file.

   Diff:
   $(git diff HEAD -- path/to/file)

   Full file:
   $(cat path/to/file)"
     ```
4. Relay Antigravity's findings and the final verdict verbatim, then add your own brief take (agree/disagree, anything it missed).
5. If issues are actionable, offer to fix them (Claude) or delegate via `antigravity-implement`.

## Notes

- Do not pass `--headless` during a review task — keep it interactive so no file edits happen.
- Antigravity has a large context window — useful for reading entire files alongside diffs, which Codex review may not do.
- This is a complement to, not a replacement for, Claude's `/code-review` and `/codex-review`.
- The combination of three perspectives (Claude + Codex + Antigravity) catches different failure modes.
