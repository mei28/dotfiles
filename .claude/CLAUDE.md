@AGENTS.md

# Claude Code Specific

The shared development standards live in `AGENTS.md` (imported above and also read by Codex
and Antigravity). Only Claude-Code-specific rules belong here.

## Tool Usage
- To understand how to use a library, **always use the Context7 MCP or lsmcp** to retrieve the latest information.

## Planning & Subagents
- Use Plan mode for non-trivial tasks. Explore the codebase with the Explore subagent and design with the Plan subagent before implementing.
- Implement in Claude Code as well. Codex / Antigravity come in only when the user asks for them;
  see the Multi-Tool AI Collaboration section in `AGENTS.md`.
