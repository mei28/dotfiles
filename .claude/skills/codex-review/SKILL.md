---
name: codex-review
description: Get a second-opinion code review from OpenAI Codex (read-only) on the current working-tree diff or branch, returning an APPROVED/WARNING/BLOCKED verdict. Use to cross-check Claude Code's own review with a different model.
---

# codex-review

Run a read-only Codex review of the current changes as a cross-check against Claude's `/code-review`.
See `docs/claude-codex.md`.

## Steps
1. Determine what to review: working-tree diff by default. Confirm the base branch (usually `main`). Use `$ARGUMENTS` to override scope (e.g. a PR number or file set).
2. Run Codex's built-in review (read-only by design; it never edits files, so approval is less of a concern):
   ```bash
   codex review --uncommitted "For each issue give file:line, severity, problem, and a fix. Cover correctness, security, error handling, missing tests, and ~/.codex/AGENTS.md standards. End with one verdict: APPROVED / WARNING / BLOCKED."
   ```
   - `--uncommitted` reviews staged + unstaged + untracked changes. Use `--base <branch>` to review against a base branch, or `--commit <sha>` for a single commit.
   - Alternatively, if the `codex` MCP server is connected, call its tool with the same instructions.
3. Relay Codex's findings and the final verdict verbatim, then add your own brief take (agree/disagree, anything Codex missed).
4. If issues are actionable, offer to fix them (Claude) or delegate via `codex-implement`.

## Notes
- `codex review` is read-only; Codex will not modify files.
- The MCP path returns final-only output, while `codex review` streams progress in the CLI.
- This is a complement to, not a replacement for, Claude's `/code-review`.
