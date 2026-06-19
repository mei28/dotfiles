---
name: changelog
allowed-tools: TodoWrite, Read, Write, Grep, Bash(git:*)
description: Generates CHANGELOG.md from git commit history following Keep a Changelog format with semantic versioning and automatic categorization
---

# Changelog Generator - Automated Release Notes

## Purpose

Automatically generates and maintains CHANGELOG.md from git commit history. Follows [Keep a Changelog](https://keepachangelog.com/) format with semantic versioning. Categorizes commits into Added, Changed, Fixed, Deprecated, Removed, and Security sections. Transforms raw git history into user-friendly release notes.

## When to Use

- ✅ Before creating a new release
- ✅ When preparing release notes
- ✅ After merging features to main branch
- ✅ For legacy projects without changelog
- ✅ When versioning APIs

## Usage

```
/changelog
/changelog --version 2.1.0
/changelog --since v2.0.0
/changelog --preview
```

**Arguments** (optional):
- `--version X.Y.Z`: Generate changelog for specific version
- `--since TAG`: Generate changelog from specific git tag/commit
- `--preview`: Show what would be generated without writing
- No arguments: Generate changelog from last tag to HEAD

## Keep a Changelog Format

### Standard Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Now removed features

### Fixed
- Bug fixes

### Security
- Vulnerabilities and security improvements

## [2.1.0] - 2024-01-15

### Added
- User authentication with OAuth 2.0
- Email notification system
- Dark mode support

### Changed
- Updated dashboard UI design
- Improved database query performance

### Fixed
- Fixed memory leak in WebSocket connection
- Resolved timezone handling bug

## [2.0.0] - 2024-01-01

### Added
- Complete API rewrite
- GraphQL support
- Real-time updates via WebSockets

### Changed
- **BREAKING**: Changed authentication from session to JWT
- **BREAKING**: Renamed `/api/v1/users` to `/api/v2/users`

### Removed
- **BREAKING**: Removed deprecated `/legacy` endpoints
- Removed support for IE11

[Unreleased]: https://github.com/user/repo/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/user/repo/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/user/repo/releases/tag/v2.0.0
```

## Commit Message Categorization

### Automatic Category Detection

The plugin uses Angular.js commit conventions to categorize changes:

| Commit Prefix | Category | Description |
|---------------|----------|-------------|
| `feat:` | **Added** | New features |
| `fix:` | **Fixed** | Bug fixes |
| `perf:` | **Changed** | Performance improvements |
| `refactor:` | **Changed** | Code refactoring |
| `style:` | _(ignored)_ | Formatting changes |
| `docs:` | _(ignored)_ | Documentation only |
| `test:` | _(ignored)_ | Test additions |
| `chore:` | _(ignored)_ | Build/tooling changes |
| `BREAKING CHANGE:` | **Changed** (marked as breaking) | Breaking changes |
| `security:` | **Security** | Security fixes |
| `deprecate:` | **Deprecated** | Deprecation notices |
| `remove:` | **Removed** | Feature removal |

### Examples

```bash
# Feature → Added
git commit -m "feat: add user profile page"
# → Added: User profile page

# Bug fix → Fixed
git commit -m "fix: resolve null pointer exception in login"
# → Fixed: Null pointer exception in login

# Breaking change → Changed (with warning)
git commit -m "feat!: change API response format

BREAKING CHANGE: Response now returns data in camelCase instead of snake_case"
# → Changed: **BREAKING**: API response format changed to camelCase

# Security fix → Security
git commit -m "security: fix SQL injection vulnerability in user search"
# → Security: SQL injection vulnerability in user search

# Multiple categories in one commit
git commit -m "feat: add password reset feature

Also fixes:
- Email validation bug
- Session timeout issue"
# → Added: Password reset feature
#    Fixed: Email validation bug, session timeout issue
```

## Real-World Example

### Before: Raw Git History

```bash
$ git log --oneline v2.0.0..HEAD

a1b2c3d feat: add OAuth 2.0 authentication
e4f5g6h fix: memory leak in WebSocket connection
i7j8k9l feat: implement dark mode
m0n1o2p refactor: improve database query performance
q3r4s5t fix: timezone handling in date picker
u6v7w8x feat: email notification system
y9z0a1b docs: update API documentation
c2d3e4f chore: bump dependencies
g5h6i7j feat!: migrate to new database schema

BREAKING CHANGE: Database tables renamed, migration required
```

### After: Generated Changelog

```markdown
## [2.1.0] - 2024-01-15

### Added
- OAuth 2.0 authentication ([a1b2c3d](https://github.com/user/repo/commit/a1b2c3d))
- Dark mode support ([i7j8k9l](https://github.com/user/repo/commit/i7j8k9l))
- Email notification system ([u6v7w8x](https://github.com/user/repo/commit/u6v7w8x))

### Changed
- **BREAKING**: Migrated to new database schema - migration required ([g5h6i7j](https://github.com/user/repo/commit/g5h6i7j))
- Improved database query performance ([m0n1o2p](https://github.com/user/repo/commit/m0n1o2p))

### Fixed
- Memory leak in WebSocket connection ([e4f5g6h](https://github.com/user/repo/commit/e4f5g6h))
- Timezone handling in date picker ([q3r4s5t](https://github.com/user/repo/commit/q3r4s5t))
```

## Semantic Versioning

### Version Bumping Strategy

The plugin suggests version bumps based on commit types:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| **BREAKING CHANGE** | Major (X.0.0) | 2.1.0 → 3.0.0 |
| **feat:** | Minor (x.Y.0) | 2.1.0 → 2.2.0 |
| **fix:**, **perf:** | Patch (x.y.Z) | 2.1.0 → 2.1.1 |
| **docs:**, **chore:** | No bump | 2.1.0 → 2.1.0 |

### Version Detection

```bash
# Detect current version from:
1. git tags (v2.1.0, 2.1.0)
2. package.json version field
3. Cargo.toml version field (Rust)
4. pyproject.toml version field (Python)
5. pom.xml version field (Java)
```

### Example: Version Suggestion

```markdown
## Version Analysis

**Current Version**: 2.1.0 (from git tag v2.1.0)
**Commits Since Last Release**: 8

**Commit Breakdown**:
- 1 breaking change (feat!)
- 3 features (feat:)
- 2 bug fixes (fix:)
- 1 refactoring (refactor:)
- 1 documentation (docs:)

**Suggested Version**: 3.0.0 (major bump due to breaking change)

**Alternative**: If you want to release features first:
1. Release v2.2.0 with features (without breaking change commit)
2. Release v3.0.0 with breaking change later
```

## Process Flow

### Step 1: Detect Current Version

```bash
# Check git tags
git describe --tags --abbrev=0

# Check package.json
Read package.json

# Check other version sources
Read Cargo.toml
Read pyproject.toml
```

### Step 2: Get Commit History

```bash
# Get commits since last tag
git log v2.0.0..HEAD --pretty=format:"%H|%s|%b|%an|%ad"

# Or get unreleased commits
git log $(git describe --tags --abbrev=0)..HEAD
```

### Step 3: Categorize Commits

Create TodoWrite checklist:

```markdown
## Changelog Generation

- [x] Detect current version (2.1.0)
- [x] Get commit history (42 commits since v2.1.0)
- [ ] Categorize commits by type
- [ ] Filter out ignored commits (docs, chore, test)
- [ ] Detect breaking changes
- [ ] Format entries
- [ ] Suggest version bump
- [ ] Update CHANGELOG.md
```

Parse each commit:
- Extract commit type (feat, fix, etc.)
- Extract commit message
- Detect breaking changes
- Extract commit hash for links
- Group by category

### Step 4: Format Changelog Entry

```markdown
## [2.2.0] - 2024-01-15

### Added
- OAuth 2.0 authentication ([a1b2c3d](https://github.com/user/repo/commit/a1b2c3d))
  - Supports Google, GitHub, and Microsoft providers
  - Includes token refresh mechanism
- Dark mode support ([i7j8k9l](https://github.com/user/repo/commit/i7j8k9l))

### Changed
- Improved database query performance by 40% ([m0n1o2p](https://github.com/user/repo/commit/m0n1o2p))

### Fixed
- Memory leak in WebSocket connection ([e4f5g6h](https://github.com/user/repo/commit/e4f5g6h))
- Timezone handling in date picker ([q3r4s5t](https://github.com/user/repo/commit/q3r4s5t))
```

### Step 5: Update CHANGELOG.md

```bash
# Check if CHANGELOG.md exists
Read CHANGELOG.md

# If exists: prepend new version
# If not: create new CHANGELOG.md with full structure

Write CHANGELOG.md
```

## Output Format

```markdown
# Changelog Generation Report

## Summary

**Current Version**: 2.1.0
**New Version**: 2.2.0 (minor bump)
**Commits Processed**: 42
**Commits Included**: 18 (24 filtered out)

**Changes by Category**:
- Added: 5 new features
- Changed: 3 improvements
- Fixed: 10 bug fixes
- Security: 0 security fixes
- Deprecated: 0 deprecations
- Removed: 0 removals

## Version Bump Rationale

**Suggested Version**: 2.2.0

**Reasoning**:
- No breaking changes detected
- 5 new features (feat:) → minor version bump
- 10 bug fixes (fix:) → would be patch, but features take precedence
- 3 performance improvements (perf:)

## Generated Changelog Preview

```markdown
## [2.2.0] - 2024-01-15

### Added
- OAuth 2.0 authentication ([a1b2c3d](https://github.com/user/repo/commit/a1b2c3d))
- Email notification system ([u6v7w8x](https://github.com/user/repo/commit/u6v7w8x))
- Dark mode support ([i7j8k9l](https://github.com/user/repo/commit/i7j8k9l))
- User profile export to PDF ([b2c3d4e](https://github.com/user/repo/commit/b2c3d4e))
- Real-time collaboration features ([c3d4e5f](https://github.com/user/repo/commit/c3d4e5f))

### Changed
- Improved database query performance by 40% ([m0n1o2p](https://github.com/user/repo/commit/m0n1o2p))
- Updated dashboard UI design ([d4e5f6g](https://github.com/user/repo/commit/d4e5f6g))
- Optimized image loading with lazy loading ([e5f6g7h](https://github.com/user/repo/commit/e5f6g7h))

### Fixed
- Memory leak in WebSocket connection ([e4f5g6h](https://github.com/user/repo/commit/e4f5g6h))
- Timezone handling in date picker ([q3r4s5t](https://github.com/user/repo/commit/q3r4s5t))
- Form validation error messages ([f6g7h8i](https://github.com/user/repo/commit/f6g7h8i))
- Session timeout on mobile devices ([g7h8i9j](https://github.com/user/repo/commit/g7h8i9j))
- API response caching issue ([h8i9j0k](https://github.com/user/repo/commit/h8i9j0k))
- Race condition in file upload ([i9j0k1l](https://github.com/user/repo/commit/i9j0k1l))
- Email template rendering ([j0k1l2m](https://github.com/user/repo/commit/j0k1l2m))
- Pagination bug in user list ([k1l2m3n](https://github.com/user/repo/commit/k1l2m3n))
- Search indexing delays ([l2m3n4o](https://github.com/user/repo/commit/l2m3n4o))
- CORS configuration for subdomains ([m3n4o5p](https://github.com/user/repo/commit/m3n4o5p))
```

## Filtered Commits

The following commits were excluded (documentation, tests, chores):

- `docs: update API documentation` ([y9z0a1b](https://github.com/user/repo/commit/y9z0a1b))
- `chore: bump dependencies` ([c2d3e4f](https://github.com/user/repo/commit/c2d3e4f))
- `test: add unit tests for auth module` ([n4o5p6q](https://github.com/user/repo/commit/n4o5p6q))
- ... (21 more)

## Next Steps

1. **Review Changelog**: Check generated entries for accuracy
2. **Edit if Needed**: Add additional context or group related changes
3. **Update Version**: Bump version in package.json to 2.2.0
4. **Create Git Tag**: `git tag -a v2.2.0 -m "Release v2.2.0"`
5. **Publish Release**: Create GitHub release with changelog

**Quick Commands**:

```bash
# Update version in package.json
npm version 2.2.0 --no-git-tag-version

# Create git tag
git tag -a v2.2.0 -m "Release v2.2.0"

# Push tag
git push origin v2.2.0

# Create GitHub release
gh release create v2.2.0 --title "v2.2.0" --notes-file <(sed -n '/## \[2.2.0\]/,/## \[/p' CHANGELOG.md)
```

---

**Generated by**: Claude Code - Changelog Plugin
**Timestamp**: 2024-01-15 14:30:00
**Repository**: https://github.com/user/repo
```

## Best Practices

### 1. Meaningful Commit Messages

**Good commits**:
```bash
feat: add user export to CSV
fix: resolve race condition in payment processing
perf: optimize image compression algorithm
```

**Bad commits**:
```bash
fix stuff
update code
changes
WIP
```

### 2. Breaking Changes

Always mark breaking changes explicitly:

```bash
# Method 1: Use ! after type
git commit -m "feat!: change API authentication method

BREAKING CHANGE: Session-based auth replaced with JWT.
Clients must update to send Bearer tokens."

# Method 2: Use BREAKING CHANGE in body
git commit -m "refactor: restructure user API

BREAKING CHANGE: /users endpoint moved to /api/v2/users"
```

### 3. Group Related Changes

```bash
# Bad: Many separate commits
git commit -m "feat: add login form"
git commit -m "feat: add login validation"
git commit -m "feat: add login error handling"

# Good: One cohesive commit
git commit -m "feat: add user login with validation and error handling"
```

### 4. Use Conventional Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 5. Keep CHANGELOG.md Updated

- Generate changelog before each release
- Review and edit generated entries
- Add context for complex changes
- Link to related issues/PRs

## Integration with Other Commands

### Release Workflow

```
1. [Complete features]
2. /test-generator       # Ensure test coverage
3. /code-review          # Final review
4. /changelog            # Generate changelog
5. [Review and edit CHANGELOG.md]
6. [Update version in package.json]
7. /auto-commit          # Commit changelog
8. [Create git tag]
9. /pr-template          # Create release PR (if needed)
10. [Publish release]
```

### Pre-Release Workflow

```
1. /changelog --preview  # Preview what will be in changelog
2. [Review breaking changes]
3. [Decide on version bump]
4. /changelog --version 3.0.0  # Generate changelog
5. [Review and edit]
```

## Advanced Features

### Custom Categories

Add custom commit types to categorization:

**CLAUDE.md configuration**:

```markdown
## Changelog Configuration

Custom categories:
- `ui:` → Changed (UI improvements)
- `a11y:` → Changed (Accessibility improvements)
- `i18n:` → Added (Internationalization)
```

### Multi-Project Changelogs

For monorepos with multiple packages:

```bash
# Generate changelog for specific package
/changelog --scope packages/api
/changelog --scope packages/web
```

### Release Notes vs Changelog

**Changelog** (CHANGELOG.md):
- Technical, detailed
- All changes included
- For developers

**Release Notes** (GitHub Releases):
- User-facing
- Highlights only
- For end users

Generate both:

```bash
# Technical changelog
/changelog --output CHANGELOG.md

# User-facing release notes
/changelog --output RELEASE_NOTES.md --user-facing
```

### Changelog Links

Automatically add links to:
- Commit hashes
- Pull requests
- Issues
- Contributors

```markdown
### Fixed
- Memory leak in WebSocket connection ([#123](https://github.com/user/repo/issues/123)) - Thanks @contributor
```

## Tips

- 💡 Run `/changelog --preview` before releases to check changes
- 💡 Use meaningful commit messages for better changelogs
- 💡 Mark breaking changes explicitly with `!` or `BREAKING CHANGE:`
- 💡 Review and edit generated changelog for clarity
- 💡 Keep unreleased changes in `[Unreleased]` section
- 💡 Link to issues/PRs for additional context
- 💡 Follow semantic versioning strictly
- 💡 Generate changelog before creating git tags

## Common Patterns

### Unreleased Changes

Keep track of changes not yet released:

```markdown
## [Unreleased]

### Added
- New dashboard widget
- CSV export for reports

### Fixed
- Login redirect issue
```

When releasing:

```bash
/changelog --version 2.3.0
# Moves [Unreleased] → [2.3.0] with date
```

### Alpha/Beta Releases

```bash
# Pre-release versions
/changelog --version 3.0.0-alpha.1
/changelog --version 3.0.0-beta.1
/changelog --version 3.0.0-rc.1

# Final release
/changelog --version 3.0.0
```

### Hotfix Releases

```bash
# Emergency bug fix
git checkout v2.1.0
git cherry-pick abc123  # The fix
/changelog --version 2.1.1
git tag v2.1.1
```

## Limitations

- **Commit Message Quality**: Depends on well-written commit messages
- **Manual Edits**: May need manual cleanup for complex releases
- **Context**: Can't infer business context from code alone
- **Grouping**: Related commits may need manual grouping
- **User Impact**: Technical changes may need user-friendly rewording

## References

**Standards**:
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
- [Conventional Commits](https://www.conventionalcommits.org/)

**Tools**:
- [git-cliff](https://git-cliff.org/) - Changelog generator
- [standard-version](https://github.com/conventional-changelog/standard-version)
- [semantic-release](https://semantic-release.gitbook.io/)
