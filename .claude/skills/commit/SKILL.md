---
name: commit
allowed-tools: TodoWrite, Bash, Grep, Read
description: Analyzes git diffs and automatically creates fine-grained commits with rule-based commit messages following Angular.js conventions. Use when you have multiple unstaged changes that need to be organized into logical commits.
---

# Auto Commit - Intelligent Git Commit Automation

## Purpose

Analyzes unstaged changes in your git repository and automatically creates well-structured, logically grouped commits with meaningful messages following Angular.js commit conventions.

## Commit Message Rules

Follow Angular.js commit guideline prefixes:

| Prefix | Usage | Example |
|--------|-------|---------|
| `feat` | New feature | `feat: add user authentication feature` |
| `fix` | Bug fix | `fix: resolve login exception handling` |
| `docs` | Documentation only | `docs: update API documentation` |
| `style` | Code formatting (no logic change) | `style: unify indentation` |
| `refactor` | Code restructuring (no behavior change) | `refactor: extract authentication logic` |
| `perf` | Performance improvement | `perf: optimize database queries` |
| `test` | Test additions/modifications | `test: add user registration tests` |
| `chore` | Build process/tooling changes | `chore: update package.json` |

### Message Guidelines

- **Language**: Write in **English by default**
  - Can be changed to Japanese if specified in CLAUDE.md or user request
  - Check project's CLAUDE.md for `## Git Workflow > Language: Japanese` setting
- **Content**: Include reasons, background, and purpose - not just "what" but "why"
- **Format**: `<prefix>: <concise description>`
- **Length**: Keep first line under 72 characters when possible
- **Detail**: Add body with more context if needed (use heredoc format)

### Language Configuration

The plugin checks for language preference in this order:

1. **User explicit request**: If user says "use Japanese" or "日本語で", use Japanese
2. **CLAUDE.md setting**: Check for commit message language preference
3. **Default**: Use English

**Example CLAUDE.md configuration**:
```markdown
## Git Workflow

### Commit Convention
Language: Japanese  # Use Japanese for commit messages
```

## Usage

Simply invoke the command when you have unstaged changes:

```
/commit
```

The command will:
1. ✅ Analyze all unstaged changes
2. ✅ Group related files logically
3. ✅ Generate appropriate commit messages
4. ✅ Create individual commits automatically
5. ✅ Verify each commit succeeds

## Process Overview

### Step 1: Initial Analysis

```bash
git status    # Get list of changed files
git diff      # Get detailed changes
```

Creates a TodoWrite task list for tracking progress.

### Step 2: File Classification & Grouping

Group files based on:

- **Functionality**: Related features together
- **Change Type**: New features, bug fixes, refactoring, etc.
- **Dependency**: Files that depend on each other
- **Scope**: Similar scope or module

**Grouping Strategy**:

1. **Single File Changes**: Commit independently if unrelated
2. **Related Feature Files**: Group into single commit (e.g., component + test + style)
3. **Bug Fix + Test**: Commit together
4. **Refactoring**: Separate from feature additions

### Step 3: Commit Execution

For each file group:

1. **Stage files**: `git add <files>`
2. **Generate message**: Analyze changes and create meaningful message
3. **Execute commit**: Use heredoc format for proper formatting
4. **Verify**: Check `git status` after each commit
5. **Update tasks**: Mark TodoWrite item as completed

### Step 4: Final Verification

```bash
git status    # Confirm no remaining changes
git log -3    # Show recent commits
```

## Implementation Details

### Change Analysis

When analyzing diffs, consider:

1. **File Path**: Infer purpose from directory structure
   - `src/components/` → likely UI feature
   - `src/utils/` → utility function changes
   - `tests/` → test additions/modifications
   - `docs/` → documentation changes

2. **Change Content**: Understand what changed
   - New functions → `feat`
   - Bug fixes → `fix`
   - Code cleanup → `refactor` or `style`
   - Performance improvements → `perf`

3. **Change Context**: Read files if needed
   - Use `Read` tool to understand broader context
   - Infer business purpose from code comments
   - Check related files for dependencies

### Commit Message Generation

**Bad Example** (too technical):
```
feat: add new function getUserData()
```

**Good Example** (business value) - English:
```
feat: add user profile retrieval feature

Implement API-based user data fetching with caching.
Introduce 5-minute in-memory cache for performance improvement.
```

**Good Example** (business value) - Japanese:
```
feat: ユーザープロフィール取得機能を追加

APIからユーザーデータを取得し、キャッシュする機能を実装。
パフォーマンス改善のため、5分間のメモリキャッシュを導入。
```

### Commit Command Format

Always use heredoc format for proper message formatting:

**English (Default)**:
```bash
git commit -m "$(cat <<'EOF'
feat: add user authentication feature

Implement OAuth 2.0 authentication flow.
Store tokens in localStorage with auto-refresh support.
EOF
)"
```

**Japanese (if configured)**:
```bash
git commit -m "$(cat <<'EOF'
feat: ユーザー認証機能を追加

OAuth 2.0を使用した認証フローを実装。
トークンはlocalStorageに保存し、自動更新に対応。
EOF
)"
```

## Error Handling

### Pre-commit Hook Failures

If pre-commit hooks fail (e.g., linting, formatting):

1. **Capture error output**: Show user the exact error
2. **Suggest fix**: Recommend running linter/formatter
3. **Retry option**: Ask if user wants to fix and retry
4. **Skip option**: Offer to skip this group and continue

**Example**:
```markdown
❌ Commit failed due to pre-commit hook

Error:
  eslint: src/component.js
    Line 15: Unexpected console.log statement

Suggestions:
1. Remove console.log statement
2. Run `npm run lint:fix`
3. Skip this commit and continue with others

What would you like to do?
```

### Merge Conflicts

If merge conflicts detected:

```markdown
⚠️ Merge conflicts detected

Please resolve conflicts manually:
  - src/config.js
  - src/utils/helper.js

Run `/commit` again after resolving conflicts.
```

### Empty Changes

If no unstaged changes:

```markdown
✅ No unstaged changes found

All changes are already committed or staged.
Use `git status` to check repository state.
```

## Best Practices

### 1. Read Files for Context

When in doubt about the purpose of changes:

```bash
# Read modified files to understand context
Read src/components/UserProfile.tsx
Read src/api/user.ts
```

This helps generate meaningful commit messages that explain "why" not just "what".

### 2. Group Logically

**Good Grouping**:
```
Group 1: feat: add user profile feature
  - src/components/UserProfile.tsx
  - src/components/UserProfile.test.tsx
  - src/components/UserProfile.module.css

Group 2: fix: improve API error handling
  - src/api/client.ts
  - src/utils/errorHandler.ts
```

**Bad Grouping**:
```
Group 1: Multiple unrelated changes
  - src/components/UserProfile.tsx (new feature)
  - src/api/client.ts (bug fix)
  - docs/README.md (documentation)
```

### 3. Commit Order

Commit in logical dependency order:

1. **Infrastructure/Config**: Build, dependencies first
2. **Core Logic**: Business logic next
3. **UI Components**: User interface after logic
4. **Tests**: Test files last
5. **Documentation**: Docs at the end

### 4. Atomic Commits

Each commit should:
- ✅ Be self-contained and functional
- ✅ Pass all tests
- ✅ Have a single clear purpose
- ❌ Mix multiple unrelated changes
- ❌ Break existing functionality

## Task Management

Use TodoWrite to track progress:

```markdown
## Auto-Commit Progress

- [x] Analyze changes (3 files modified)
- [x] Group files into commits
- [ ] Commit 1/3: feat: add user authentication
- [ ] Commit 2/3: test: add authentication tests
- [ ] Commit 3/3: docs: update authentication documentation
```

Update after each commit:

```markdown
## Auto-Commit Progress

- [x] Analyze changes (3 files modified)
- [x] Group files into commits
- [x] Commit 1/3: feat: add user authentication
- [ ] Commit 2/3: test: add authentication tests
- [ ] Commit 3/3: docs: update authentication documentation
```

## Output Format

Present clear, actionable information:

```markdown
## Auto-Commit Analysis

### Changes Detected
- 5 files modified
- 2 files added
- 1 file deleted

### Proposed Commits

#### Commit 1: feat: add dark mode feature
**Files**:
- src/theme/darkMode.ts (new)
- src/components/ThemeToggle.tsx (new)
- src/App.tsx (modified)

**Changes**:
- Implement theme switching functionality
- Persist user preferences
- Sync with system settings

---

#### Commit 2: test: add dark mode tests
**Files**:
- src/theme/darkMode.test.ts (new)
- src/components/ThemeToggle.test.tsx (new)

**Changes**:
- Unit tests for theme switching
- Verify localStorage behavior

---

### Execution Plan

1. Stage and commit feat changes
2. Stage and commit test changes
3. Verify all commits
4. Display final git log

Proceed with commits? (Will execute automatically)
```

## Examples

### Example 1: Single Feature with Tests

**Changes**:
```
M  src/auth/login.ts
A  src/auth/login.test.ts
M  src/components/LoginForm.tsx
```

**Commits** (English):
```
Commit 1: feat: implement login functionality

Add OAuth authentication flow and token management.
Support persistent login state across sessions.

Files:
- src/auth/login.ts
- src/components/LoginForm.tsx

---

Commit 2: test: add login functionality tests

Implement test cases for auth flow and token validation.

Files:
- src/auth/login.test.ts
```

### Example 2: Bug Fix

**Changes**:
```
M  src/api/client.ts
M  src/utils/retry.ts
```

**Commit** (English):
```
fix: resolve infinite loop in API retry logic

Fix network error handling to prevent infinite retries.
Limit to maximum 3 retry attempts, then return error.

Files:
- src/api/client.ts
- src/utils/retry.ts
```

### Example 3: Refactoring

**Changes**:
```
M  src/services/userService.ts
M  src/services/authService.ts
D  src/services/legacyAuth.ts
```

**Commit** (English):
```
refactor: consolidate authentication services

Remove legacy auth logic and migrate to unified interface.
Reduce code duplication and improve maintainability.

Files:
- src/services/userService.ts
- src/services/authService.ts
- src/services/legacyAuth.ts (deleted)
```

## Integration with Project Standards

### Reading CLAUDE.md

Always check project-specific commit conventions:

```bash
Read CLAUDE.md
```

Look for:
- **Language preference**: English or Japanese
- Custom commit prefixes
- Specific formatting rules
- Required commit message sections
- Pre-commit hook requirements

**Example CLAUDE.md**:
```markdown
## Git Workflow

### Commit Convention
- Language: Japanese  # Use Japanese instead of English
- Prefix: Use Angular.js guidelines
- Include rationale, context, and purpose
```

### Adapting to Project Style

If CLAUDE.md specifies different conventions:

1. **Respect language preference**: Use specified language (English/Japanese)
2. **Respect project rules**: Override defaults with project standards
3. **Maintain consistency**: Match existing commit history style
4. **Note deviations**: Inform user if project uses non-standard conventions

## Workflow Example

**Complete session**:

```
User: /commit

Assistant: Analyzing changes...

[TodoWrite: Create task list]

## Auto-Commit Analysis

### Changes Detected
- src/auth/login.ts (modified)
- src/auth/login.test.ts (new)
- src/components/LoginForm.tsx (modified)
- docs/AUTH.md (modified)

### Language
Using **English** (default). To use Japanese, add to CLAUDE.md:
```
## Git Workflow
Language: Japanese
```

### Proposed Commits

#### Commit 1: feat: implement login functionality
**Files**: src/auth/login.ts, src/components/LoginForm.tsx
**Reason**: New feature (OAuth authentication flow)

#### Commit 2: test: add login functionality tests
**Files**: src/auth/login.test.ts
**Reason**: Test code addition

#### Commit 3: docs: update authentication documentation
**Files**: docs/AUTH.md
**Reason**: Documentation update

### Executing commits...

[git add src/auth/login.ts src/components/LoginForm.tsx]
[git commit with message]
✅ Commit 1/3 completed

[git add src/auth/login.test.ts]
[git commit with message]
✅ Commit 2/3 completed

[git add docs/AUTH.md]
[git commit with message]
✅ Commit 3/3 completed

### Summary
✅ 3 commits created successfully
✅ All changes committed
✅ No unstaged changes remaining

Run `git log -3` to see recent commits.
```

## Related Commands

- `EnterPlanMode`: Plan implementation before making changes
- `/dig`: Clarify requirements before coding
- `/deslop`: Clean up code before committing
- `/pr-template`: Generate PR description after commits

## Tips

- 💡 Run `/deslop` before `/commit` to ensure code quality
- 💡 Use `/dig` to clarify requirements before implementing
- 💡 Read CLAUDE.md to understand project commit conventions
- 💡 Check `git log` after commits to verify messages
- 💡 Use `git commit --amend` if you need to fix the last commit message

## Limitations

- Does not handle merge conflicts (reports to user)
- Does not force push or rewrite history
- Respects pre-commit hooks (fails if hooks reject)
- Requires manual resolution for complex scenarios

## Security Notes

- Never commits files with secrets (.env, credentials, etc.)
- Warns user if sensitive files detected
- Respects .gitignore patterns
- Does not override user git config

## References

- Angular.js Commit Guidelines: https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#commits
- Conventional Commits: https://www.conventionalcommits.org/
- Git Best Practices: https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project
