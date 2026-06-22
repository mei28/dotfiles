# Gemini CLI — Project Instructions

This is a dotfiles repository managed alongside Claude Code and Codex.
Shared development standards apply regardless of which AI tool is invoked.

## Development Standards

Follow the standards in `.claude/AGENTS.md`. Key points:

- Think in English; respond in Japanese
- Fail fast — no fallback code, no suppressed errors, no defensive "just in case" logic
- YAGNI, DRY, KISS
- Angular.js commit convention (`feat:`, `fix:`, `refactor:`, etc.)
- Ask before implementing when uncertain; never proceed on assumptions

## Multi-Tool Context

Claude Code, Codex, and Gemini CLI are used together in this project.
The current primary roles are:

- Claude Code: research and planning
- Codex: implementation and review
- Gemini: independent review perspective, large-context analysis

For the multi-tool collaboration guide, read `docs/gemini.md`.

## Review Verdict Format

When performing code reviews, end with exactly one of:

- `APPROVED` — no significant issues found
- `WARNING` — minor issues worth noting, not blocking
- `BLOCKED` — critical bugs, security issues, or standards violations

## Constraints

- Do not commit or push unless explicitly instructed
- Report file:line for every issue found
