# Development Standards & Coding Conventions

> Single source of truth shared by all AI coding agents (Claude Code, Codex, ...).
> Claude Code loads this via `@AGENTS.md` in `CLAUDE.md`; Codex reads `~/.codex/AGENTS.md`
> (symlinked to this file). See `docs/claude-codex.md` for the dual-tool workflow.

## Top-Level Rules

- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- For temporary notes for design, create a markdown in `.tmp` and save it.
- Please respond critically and without pandering to my opinions, but please don't be forceful in your criticism.
- Proactively propose improvements and superior implementation patterns when you notice them.

## Code Design & Quality

- **Separation of concerns**: one file, one clear role; organize directories by related features
- **Function decomposition**: break long functions into small, readable units
- **Reusability**: modularize common operations to avoid duplication
- **Naming**: use clear, purpose-driven names for functions and classes
- **Readability first**: write code other developers can easily understand
- **Meaningful comments**: comment complex logic (Japanese comments acceptable for domain-specific terms)

## Error Handling & Implementation Policy

### Prohibited Practices
- Don't write fallback code
- Fail explicitly on errors (don't suppress them)
- Don't add "just in case" defensive code
- Don't create alternative implementations without confirmation

### Implementation Policy
- **Fail fast**: Make errors explicit and immediate
- **Ask questions before implementation** if uncertain
- **Don't proceed on assumptions**: Seek confirmation when unsure

## Documentation Philosophy

- **Code shows HOW**: Implementation details
- **Tests show WHAT**: Clear test objectives
- **Commits show WHY**: Rationale for changes
- **Comments show WHY NOT**: Reasoning for alternative approaches not taken

## Design Principles

- **YAGNI (You Aren't Gonna Need It)**: Don't build features not currently needed
- **DRY (Don't Repeat Yourself)**: Avoid code duplication
- **KISS (Keep It Simple Stupid)**: Maintain simplicity

## TDD Workflow (t-wada style)

- 🔴 Red: write one failing test at a time (compile errors OK) → 🟢 Green: minimal implementation to pass (fake implementation / hardcoded returns acceptable) → 🔵 Refactor: clean up after tests pass
- Take small steps; triangulate with 2nd/3rd test cases to generalize; direct implementation when obvious
- Test uncertain areas first; immediately add new ideas to the test TODO list
- Commit frequently when tests pass, one feature per commit:
  - 🔴 `test: add failing test for [feature]`
  - 🟢 `feat: implement [feature] to pass test`
  - 🔵 `refactor: [description]`

## Task Management

- Use `just` as the task runner: centralize build, test, deploy commands in the justfile
- Ensures reproducible execution across team members; document recurring commands as recipes

## Technical Writing Guidelines

### Avoid AI-style List Formatting
- No emphasis prefixes or emoji decorators in lists: avoid `**Important**:`, `✅`, `💡`, `🔥`, `🚀`, etc.

### Avoid Hyperbolic Expressions
Replace vague superlatives with specifics:
- "revolutionary" / "game-changer" / "paradigm shift" → describe the specific transformation or impact
- "ultimate" / "fast" / "significantly" / "efficient" → give measurable metrics ("under 50ms", "200% improvement", "30% memory reduction")
- "completely/all" → specify scope ("many", "major")
- "magical" / "supercharge" / "unleash potential" → describe the concrete gain or new opportunity
- "redefine industry" / "change the future" / "inevitable change" → explain the specific new perspective and why it matters

### Writing Clarity
- Conciseness: "first and foremost" → "first"; "be able to" → "can"; "need to" → imperative; "make changes to" → "change"
- Active voice with direct subject-verb-object structure
- One idea per sentence (target ~50 characters); remove unnecessary connectives
- Unify terminology, UI element names, and tone throughout

### Japanese Technical Writing
When writing or revising Japanese technical prose — documentation, READMEs, design notes, articles, book/manuscript drafts, and other substantial written output — follow the `japanese-tech-writing` standards.
- Claude Code: consult/invoke the `japanese-tech-writing` skill.
- Codex: read and apply `~/.claude/skills/japanese-tech-writing/SKILL.md`.

## Git Workflow

### Pre-execution Confirmation Rules
- Always request user confirmation before commit, push, and PR creation
- Present a clear summary of changes and impact scope

### Commit Messages
- Angular.js prefixes: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`; include rationale, context, and purpose
- **No CLAUDE CODE signatures in commits**
- Grouping strategy and message details: `commit` skill (Codex: read `~/.claude/skills/commit/SKILL.md`)

### Worktree Usage
- When instructed, isolate feature-branch work in a worktree via `bonsai` (avoid raw `git worktree`):
  `bonsai add -c <branch> --base <base-branch>` → `bonsai cd <branch>` → after merge `bonsai remove <branch>`
- Check current state with `bonsai list` or `bonsai status`

## Multi-Tool AI Collaboration

Three AI CLIs work together: Claude Code orchestrates; Codex and Antigravity (`agy`) execute tasks and return results.
Claude does not blindly accept delegated output — it evaluates correctness, standards adherence, and quality before accepting.

| Role | Tool |
|---|---|
| Orchestrate / Plan / Evaluate | Claude Code (primary) |
| Implement | Codex (primary), Antigravity (secondary) |
| Review | All three (multi-perspective cross-check) |

| Action | Skill |
|---|---|
| Implement | `/codex-implement`, `/antigravity-implement` |
| Review | `/codex-review`, `/antigravity-review` |
| Handoff | `/handoff` (writes `.tmp/progress.md`) |

When any tool nears its usage limit, run `/handoff` and let another tool resume from `.tmp/progress.md`.
Operational guides: `docs/claude-codex.md` (Claude ↔ Codex), `docs/antigravity.md` (Antigravity CLI).
All three tools share this file for behavioral consistency.
