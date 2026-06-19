@AGENTS.md

# Claude Code Specific

The shared development standards live in `AGENTS.md` (imported above and also read by Codex).
Only Claude-Code-specific rules belong here.

## Tool Usage
- To understand how to use a library, **always use the Context7 MCP or lsmcp** to retrieve the latest information.
- **After using Write or Edit tools, ALWAYS verify the actual file contents using the Read tool**, regardless of what the system-reminder says. The system-reminder may incorrectly show "(no content)" even when the file has been successfully written.

## Planning & Subagents
- Use Plan mode for non-trivial tasks. Explore the codebase with the Explore subagent and design with the Plan subagent before implementing.
- Keep research (Claude Code) and implementation (Codex) separated per the Claude/Codex Collaboration Workflow in `AGENTS.md`.

## Delegating to Codex
- Hand implementation/review to Codex with the `codex-implement` / `codex-review` skills, or `codex exec -s workspace-write` / `codex review --uncommitted`.
- Before switching tools (e.g. near a usage limit), run the `handoff` skill to update `.tmp/progress.md`.
- See `docs/claude-codex.md` for the full dual-tool operating guide.
