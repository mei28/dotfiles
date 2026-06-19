Review the current changes (read-only). Do not modify files.

Scope: the working-tree diff against the base branch. Run `git diff` (and `git diff --staged`) to see it;
if the branch is already committed, review `git diff <base>...HEAD`.

For each issue report: file:line, severity, what is wrong, and a concrete fix suggestion.
Cover: correctness/logic bugs, security, error handling, missing tests, and violations of the shared
standards in `~/.codex/AGENTS.md` (no fallback/defensive code, fail fast, DRY/KISS/YAGNI, naming).

End with one overall verdict:
- APPROVED  — safe to proceed
- WARNING   — proceed with noted fixes
- BLOCKED   — must fix before proceeding

Be concise. Prioritize high-confidence, high-impact findings over nitpicks.
