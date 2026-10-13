@AGENTS.md

# Claude Code Specific

The shared development standards live in `AGENTS.md` (imported above and also read by Codex
and Antigravity). Only Claude-Code-specific rules belong here.

## Planning & Subagents
- Use Plan mode for non-trivial tasks. Explore the codebase with the Explore subagent and design with the Plan subagent before implementing.
- Implement in Claude Code as well. Codex / Antigravity come in only when the user asks for them;
  see the Multi-Tool AI Collaboration section in `AGENTS.md`.

## Artifacts
- Never create or publish an Artifact unless the user explicitly asks for one in the current
  request: they name an artifact, or ask for a claude.ai page or link. This overrides the
  `Artifact` tool's guidance to publish finished work, write-ups, and reports unprompted.
- A request for 資料, a document, a report, slides, or a write-up is not a request for an
  Artifact. Write it as a local file (Markdown unless the user names another format) or answer
  in the reply.
- Without that request, make no publishing call to `Artifact` (`quickstart` and `type_url`
  creates included), do not load the `artifact-*` skills or `anthropic-skills:docs`, and do not
  offer to publish the result.
- An explicit request covers that one artifact and its later updates, not the next document.
