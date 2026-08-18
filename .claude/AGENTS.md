# Development Standards & Coding Conventions

> Single source of truth shared by all AI coding agents (Claude Code, Codex, Antigravity).
> Claude Code loads this via `@AGENTS.md` in `CLAUDE.md`; Codex reads `~/.codex/AGENTS.md`
> (symlinked to this file); Antigravity reaches it via each repo's `GEMINI.md`.

## Skills

Skills live in `~/.claude/skills/<name>/SKILL.md`. That path resolves for all three tools.
- Claude Code: invoke the skill by name.
- Codex / Antigravity: read the file before starting the work it covers.

Below, "the `x` skill" means exactly this. Each skill's `description` states its own trigger.

## Language

- Think in whichever language you perform best in; English and Chinese are both fine.
- Always respond to me in Japanese, whatever language you thought in. No exceptions.
- Code, comments, commit messages, and PR bodies are English. Japanese is acceptable for
  domain-specific terms in comments.
- Japanese prose written for humans follows the `japanese-tech-writing` skill. Add the
  `cognitive-rhythm-writing` skill for anything meant to be read straight through, and to
  diagnose drafts that are accurate but flat.

## Hard Rules

Violating any of these sends the work back. There are no exceptions.

- No fallback code.
- Fail explicitly on errors. Never suppress them.
- Fail fast: make errors explicit and immediate.
- No "just in case" defensive code.
- Never create an alternative implementation without confirming first.
- Never proceed on an assumption. Ask before implementing when uncertain.
- No implementation code before a failing test has been run and watched fail: the `tdd` skill.
- Structural and behavioral changes never share a commit; the structural one goes first:
  the `tidy-first` skill.
- Ask before commit, push, and PR creation. Present what changed and its blast radius.
- Ask before closing a pane, tab, or workspace, and before removing a worktree. Merging is not
  permission to tear down. Leave the worktree standing until told otherwise.
- Never add CLAUDE CODE signatures or `Co-Authored-By` trailers to commits.
- Commit only when the test suite passes and linter/type warnings are resolved.

## Defaults

Principles, not absolutes. Departing from one is fine; say why.

- Separation of concerns: one file, one clear role; organize directories by related features.
- Function decomposition: break long functions into small, readable units.
- Reusability: modularize common operations to avoid duplication.
- Naming: use clear, purpose-driven names for functions and classes.
- Readability first: write code other developers can easily understand.
- Meaningful comments: comment complex logic.
- YAGNI: don't build features not currently needed.
- DRY: avoid code duplication.
- KISS: maintain simplicity.
- Code shows HOW, tests show WHAT, commits show WHY, comments show WHY NOT.
- Keep documentation up to date with code changes.

## Working Rules

- Run independent operations concurrently, not sequentially.
- Keep design scratch notes in `.tmp/*.md`.
- Respond critically and without pandering to my opinions, but don't be forceful about it.
- Proactively propose improvements and superior implementation patterns when you notice them.
- Use `just` as the task runner: centralize build, test, and deploy commands in the justfile
  so execution is reproducible across machines. Document recurring commands as recipes.

## Technical Writing Guidelines

Applies to every text you produce: chat replies, commit messages, PR bodies, code comments,
and generated documentation. Worked examples and the full norms: the `tech-writing` skill.

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

## Git Workflow

Confirmation, signatures, and the test gate are in Hard Rules.

- Angular.js prefixes: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`;
  include rationale, context, and purpose in the body.
- Grouping strategy and message details: the `commit` skill.
- When instructed, isolate feature-branch work in a worktree via `bonsai` (avoid raw `git worktree`):
  `bonsai add -c <branch> --base <base-branch>` → `bonsai cd <branch>` → after merge `bonsai remove <branch>`.
  Check current state with `bonsai list` or `bonsai status`.
  Skip the worktree when the change is too small to be worth one, or when the files have to be
  edited in place to take effect. Say which of the two applies and keep working in the main tree.

## Multi-Tool AI Collaboration

Claude does not blindly accept delegated output — it evaluates correctness, standards adherence,
and quality before accepting.

| Role | Tool |
|---|---|
| Orchestrate / Plan / Evaluate | Claude Code (primary) |
| Implement | Codex (primary), Antigravity (secondary) |
| Review | All three (multi-perspective cross-check) |

| Action | Skill |
|---|---|
| Implement | `codex-implement`, `antigravity-implement` |
| Review | `codex-review`, `antigravity-review` |
| Handoff | `handoff` (writes `.tmp/progress.md`) |

When any tool nears its usage limit, run `handoff` and let another tool resume from `.tmp/progress.md`.
Operational guides: `~/dotfiles/docs/claude-codex.md` (Claude ↔ Codex),
`~/dotfiles/docs/antigravity.md` (Antigravity CLI).
All three tools share this file for behavioral consistency.
