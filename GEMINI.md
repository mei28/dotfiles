# Antigravity CLI — Project Instructions

This is a dotfiles repository managed alongside Claude Code and Codex.

## Development Standards

Read and follow `.claude/AGENTS.md` — the single source of truth for development
standards shared by all AI tools. Do not rely on summaries; read the file itself.

## Multi-Tool Context

- Claude Code: the default for every phase (research, planning, implementation, review)
- Codex / Antigravity: brought in only when the user asks — implementation, or an independent
  review with large-context analysis

For the collaboration guide, read `docs/antigravity.md`.

## Review Verdict Format

When performing code reviews, end with exactly one of:

- `APPROVED` — no significant issues found
- `WARNING` — minor issues worth noting, not blocking
- `BLOCKED` — critical bugs, security issues, or standards violations

## Constraints

- Do not commit or push unless explicitly instructed
- Report file:line for every issue found
