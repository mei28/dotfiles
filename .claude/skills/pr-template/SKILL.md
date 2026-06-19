---
name: pr-template
allowed-tools: TodoWrite, Read, Write, Bash(mkdir:*), Bash(gh pr view:*), Bash(gh pr diff:*)
description: Generates comprehensive PR descriptions in English (default) or Japanese by analyzing pull request changes using GitHub CLI
---

# PR Template Generator

## Purpose

Analyzes GitHub pull requests and automatically generates comprehensive, well-structured PR descriptions following established template formats. Generates in English by default, with optional Japanese output based on configuration.

## Usage

```
/pr-template <PR_NUMBER>
```

**Examples**:
```
/pr-template 123
/pr-template 456
```

The PR number is available as `$ARGUMENTS` variable.

## Language Configuration

The plugin generates PR descriptions in **English by default**.

To use Japanese, configure in CLAUDE.md:

```markdown
## PR Template

Language: Japanese  # Use Japanese for PR descriptions
```

Or user can explicitly request Japanese when invoking:
```
User: /pr-template 123 in Japanese
User: /pr-template 123 日本語で
```

## Process Overview

### Step 1: Retrieve PR Information

```bash
gh pr view $ARGUMENTS
```

Extracts:
- PR title
- PR description (if any)
- Author
- Status (open/merged/closed)
- Labels
- Reviewers
- Branch names

### Step 2: Analyze Changes

```bash
gh pr diff $ARGUMENTS
```

Analyzes:
- Modified files and line changes
- Additions vs deletions
- File types (source, test, docs, config)
- Change patterns (new features, bug fixes, refactoring)

### Step 3: Investigate Context

When needed, use Read tool to understand context:

```bash
# Read modified files for deeper understanding
Read src/auth/login.ts
Read tests/auth/login.test.ts
```

**When to Read Files**:
- Understanding modified file purposes
- Inferring business logic and intent
- Identifying architectural patterns
- Understanding test coverage
- Checking related documentation

**Optimize Token Usage**:
- Only read files when diff alone is insufficient
- Read selectively (specific sections if possible)
- Prioritize smaller files

### Step 4: Generate Template

Create comprehensive PR description following the template format.

### Step 5: Save Template

```bash
mkdir -p .tmp
# Save to .tmp/pr-template-<PR_NUMBER>.md
```

## PR Template Format

### Section 1: Overview (概要)

**Purpose**: Explain the "why", "what", and "how" of the changes

**Requirements**:
- 1-3 concise lines
- Business value and purpose
- Background context
- Main objectives

**Example (English - Default)**:
```markdown
## Overview

Improved user authentication performance.
API response time reduced from 200ms to 50ms average, enhancing user experience.
Achieved through token validation optimization and cache mechanism introduction.
```

**Example (Japanese)**:
```markdown
## 概要

ユーザー認証機能のパフォーマンス改善を実施しました。
APIレスポンス時間が平均200msから50msに短縮され、ユーザー体験が向上します。
トークン検証ロジックの最適化とキャッシュ機構の導入により実現しました。
```

### Section 2: Changes/Additions (修正内容・追加内容)

**Purpose**: Detailed breakdown of all modifications

**Requirements**:
- Categorize changes (bug fixes, new features, refactoring, tests, docs)
- List specific files with line numbers
- Explain technical implementation
- Use markdown formatting for readability

**Example (English - Default)**:
```markdown
## Changes/Additions

### New Features
- **Token Cache Mechanism** (`src/auth/tokenCache.ts`)
  - Implement 5-minute token cache using Redis
  - Achieve 90% cache hit rate
  - L45-120: Cache logic implementation

### Performance Improvements
- **Authentication API Optimization** (`src/api/auth.ts`)
  - Optimize database queries (resolve N+1 problem)
  - L78-95: Reduce DB calls through query joining

### Tests
- **Cache Feature Tests** (`tests/auth/tokenCache.test.ts`)
  - Add 15 unit test cases
  - Achieve 95% coverage

### Documentation
- **Authentication Flow Diagram** (`docs/auth-flow.md`)
  - Add updated flow diagram including cache mechanism
```

### Section 3: 動作確認 (Testing/Verification)

**Purpose**: Suggest appropriate testing approaches based on changes

**Requirements**:
- Identify critical test scenarios
- Recommend functionality verification steps
- Consider edge cases and error conditions
- Focus on practical testing

**Example**:
```markdown
## 動作確認

### 必須確認項目
- [ ] 新規ユーザーログインが正常に動作すること
- [ ] トークンキャッシュが5分後に期限切れになること
- [ ] キャッシュミス時にDB取得にフォールバックすること

### パフォーマンス確認
- [ ] ログインAPIのレスポンスが100ms以内であること
- [ ] 1000件の同時リクエストを処理できること

### エッジケース
- [ ] Redisダウン時の動作（DB直接取得にフォールバック）
- [ ] 無効なトークンのキャッシュ防止
- [ ] キャッシュクリア機能の動作確認
```

### Section 4: レビュー観点 (Review Focus) - Optional

**Purpose**: Highlight areas requiring special attention

**When to Include**:
- Complex algorithmic changes
- Security-sensitive modifications
- Performance-critical code
- Architectural changes
- Breaking changes

**Example**:
```markdown
## レビュー観点

### セキュリティ
- トークン検証ロジックの安全性（`src/auth/tokenCache.ts` L65-80）
- キャッシュキーの衝突防止策

### パフォーマンス
- Redisの接続プーリング設定（`src/config/redis.ts` L12-25）
- メモリ使用量の監視

### 破壊的変更
- なし（後方互換性を維持）
```

### Section 5: 補足・参考 (Additional Notes)

**Purpose**: Include relevant supplementary information

**Include**:
- New library additions with documentation links
- Reference materials or inspiration sources
- Breaking changes or migration notes
- Performance implications
- Future improvements

**Example**:
```markdown
## 補足・参考

### 新規ライブラリ
- **ioredis** (v5.3.0)
  - Redisクライアントライブラリ
  - ドキュメント: https://github.com/redis/ioredis
  - 接続プーリングとクラスタサポートのため採用

### 参考資料
- [JWT Best Practices](https://example.com/jwt-best-practices)
- [Redis Caching Patterns](https://example.com/redis-patterns)

### パフォーマンス結果
| 項目 | 変更前 | 変更後 | 改善率 |
|------|--------|--------|--------|
| ログインAPI | 200ms | 50ms | 75% |
| トークン検証 | 50ms | 5ms | 90% |

### 今後の改善案
- トークンリフレッシュの自動化
- マルチリージョン対応のキャッシュ同期
```

## Implementation Instructions

### Analysis Strategy

1. **Understand PR Purpose**:
   - Read PR title and existing description
   - Infer from file changes if description is minimal
   - Read key files when needed to understand context

2. **Categorize Changes**:
   - **New Features**: New files or major functionality additions
   - **Bug Fixes**: Fixes to existing functionality
   - **Refactoring**: Code restructuring without behavior change
   - **Performance**: Optimizations and improvements
   - **Tests**: Test additions or modifications
   - **Documentation**: Docs, comments, README changes
   - **Configuration**: Build, dependencies, CI/CD changes

3. **Extract Technical Details**:
   - File paths and line numbers
   - Function/class names
   - Algorithm changes
   - Data structure modifications
   - API changes

4. **Infer Business Value**:
   - Why was this change needed?
   - What problem does it solve?
   - Who benefits from this change?
   - What's the expected impact?

### Template Generation Rules

1. **Language**: Write in **English by default**
   - Use Japanese only if configured in CLAUDE.md or explicitly requested
   - Check for language preference before generating
2. **Be Comprehensive**: Provide detailed information
3. **Stay Concise**: Avoid verbosity, focus on key points
4. **Use Markdown**: Proper formatting for readability
5. **Actionable Content**: Focus on information useful for reviewers

### Error Handling

| Error | Response |
|-------|----------|
| **No PR number** | `PRナンバーを指定してください。使用方法: /pr-template <PR_NUMBER>` |
| **PR not found** | `指定されたPRが見つかりません。PRナンバー ${ARGUMENTS} を確認してください。` |
| **No changes** | `このPRには変更が検出されませんでした。` |
| **gh CLI not installed** | `GitHub CLI (gh) がインストールされていません。https://cli.github.com/ からインストールしてください。` |
| **Not authenticated** | `GitHub CLI にログインしていません。'gh auth login' を実行してください。` |

## Output Format

After generating template, present summary:

```markdown
## PR Template Generated

**PR**: #123 - Add user authentication
**Files Changed**: 5 files (+245, -32 lines)
**Template Saved**: `.tmp/pr-template-123.md`

### Summary
- 概要: 3行で背景と目的を説明
- 修正内容: 3カテゴリー（新機能、テスト、ドキュメント）
- 動作確認: 8項目の確認事項
- 補足: 新規ライブラリ2件、パフォーマンス結果

### Next Steps
1. Review the generated template: `.tmp/pr-template-123.md`
2. Edit if needed to add project-specific details
3. Copy content to PR description on GitHub

Template is ready to use! 🎉
```

## Examples

### Example 1: New Feature PR

**PR**: #456 - "Add dark mode support"

**Generated Template**:
```markdown
## 概要

ダークモード機能を実装し、ユーザーが好みの表示テーマを選択できるようになりました。
システム設定との自動連携により、ユーザー体験が向上します。
ユーザー設定の永続化にも対応しています。

## 修正内容・追加内容

### 新機能
- **ダークモードテーマ** (`src/theme/darkMode.ts`)
  - ライト/ダークテーマの定義
  - システム設定の自動検出
  - L1-85: テーマ切り替えロジック

- **テーマトグルコンポーネント** (`src/components/ThemeToggle.tsx`)
  - ヘッダーに配置されたトグルスイッチ
  - アニメーション付きの滑らかな切り替え
  - L12-45: コンポーネント実装

### 状態管理
- **テーマContextの追加** (`src/contexts/ThemeContext.tsx`)
  - グローバルテーマ状態の管理
  - localStorageへの永続化
  - L20-60: Context Provider実装

### テスト
- **ダークモードテスト** (`tests/theme/darkMode.test.ts`)
  - テーマ切り替えのユニットテスト
  - ローカルストレージの動作確認
  - カバレッジ92%達成

## 動作確認

### 必須確認項目
- [ ] ヘッダーのトグルボタンでテーマが切り替わること
- [ ] ページリロード後もテーマ設定が保持されること
- [ ] システム設定と同期すること（初回訪問時）

### 表示確認
- [ ] 全ページでダークモードが正しく表示されること
- [ ] テキストの可読性が十分であること
- [ ] ボタンやリンクの視認性が確保されていること

## 補足・参考

### 参考実装
- Material-UI のテーマシステムを参考
- `prefers-color-scheme` CSS メディアクエリを活用

### 今後の改善案
- ユーザープロフィールへのテーマ設定保存（クロスデバイス同期）
- カスタムテーマカラーの選択機能
```

**Saved to**: `.tmp/pr-template-456.md`

### Example 2: Bug Fix PR

**PR**: #789 - "Fix memory leak in WebSocket connection"

**Generated Template**:
```markdown
## 概要

WebSocket接続のメモリリークを修正しました。
長時間稼働時のメモリ使用量増加問題が解消され、システムの安定性が向上します。

## 修正内容・追加内容

### バグ修正
- **WebSocket接続管理** (`src/services/websocket.ts`)
  - 接続切断時のイベントリスナー解除漏れを修正
  - L145-160: cleanup関数の追加
  - L78: useEffect のdependency配列を修正

### テスト
- **メモリリークテスト** (`tests/services/websocket.test.ts`)
  - 接続・切断を1000回繰り返すストレステスト追加
  - メモリ使用量の監視テスト

## 動作確認

### 必須確認項目
- [ ] WebSocket接続・切断を繰り返してもメモリが増加しないこと
- [ ] 通常のWebSocket通信が正常に動作すること
- [ ] エラー時の切断処理が正しく動作すること

### パフォーマンス確認
- [ ] 24時間稼働後のメモリ使用量が安定していること

## レビュー観点

### メモリ管理
- cleanup関数の実装が適切か（`src/services/websocket.ts` L145-160）
- イベントリスナーの解除が確実に実行されるか

## 補足・参考

### バグの原因
- React の useEffect cleanup関数でイベントリスナーを解除していなかった
- 接続を繰り返すたびにリスナーが蓄積

### 再発防止
- ESLint ルール `react-hooks/exhaustive-deps` を有効化
- メモリリークチェックを CI に追加
```

**Saved to**: `.tmp/pr-template-789.md`

## Best Practices

### 1. Read Files Selectively

**Don't**:
```bash
# Reading all files unnecessarily
Read src/components/UserProfile.tsx
Read src/api/users.ts
Read src/utils/validation.ts
Read src/styles/userprofile.css
Read tests/user.test.ts
```

**Do**:
```bash
# Read only when diff is insufficient
# Prioritize key files for understanding context
Read src/components/UserProfile.tsx  # Main change
Read tests/user.test.ts               # To understand test coverage
```

### 2. Infer Business Value

**Don't** (English):
```markdown
## Overview
Added getUserData function.
```

**Do** (English):
```markdown
## Overview
Implemented user profile retrieval feature to accelerate dashboard loading.
API response caching enables instant loading from second access onwards.
```

### 3. Be Specific with Line Numbers

**Don't**:
```markdown
- Modified `src/auth.ts`
```

**Do**:
```markdown
- **Token Validation Logic** (`src/auth.ts`)
  - L45-78: JWT validation implementation
  - L92-105: Token refresh handling
```

### 4. Categorize Clearly

Group changes logically (use English or Japanese based on language setting):
- New Features (新機能)
- Bug Fixes (バグ修正)
- Refactoring (リファクタリング)
- Performance (パフォーマンス改善)
- Tests (テスト)
- Documentation (ドキュメント)
- Configuration (設定変更)

### 5. Focus on Reviewers

What would a reviewer want to know?
- Why was this change needed?
- What's the impact?
- What should they focus on?
- Are there any risks?
- How can they verify it works?

## Integration with Other Commands

### Recommended Workflow

```
1. Make changes to codebase
2. Run /deslop to clean up AI-generated code
3. Run /commit to create logical commits
4. Create PR on GitHub
5. Run /pr-template <PR_NUMBER> to generate description
6. Copy template content to PR
7. Request review
```

### With Project Documentation

Always check for project-specific templates:

```bash
# Check for existing PR template
Read .github/PULL_REQUEST_TEMPLATE.md
Read docs/PR_GUIDELINES.md
```

Adapt generated template to match project standards.

## Tips

- 💡 Run immediately after creating PR for freshest context
- 💡 Edit generated template to add project-specific details
- 💡 Save custom sections to reuse across similar PRs
- 💡 Include screenshots for UI changes (add manually)
- 💡 Link to related issues/PRs in 補足 section

## Limitations

- Does not include screenshots (add manually if needed)
- May not capture all business context (review and edit)
- Requires GitHub CLI (`gh`) installed and authenticated
- Works best with PRs that have clear, focused changes
- Language must be configured for non-English output

## Security Notes

- Only accesses public PR information via GitHub CLI
- Does not modify PR or push changes
- Template saved locally in `.tmp/` directory
- Respects GitHub authentication and permissions

## References

- GitHub CLI Documentation: https://cli.github.com/manual/
- Effective PR Descriptions: Best practices for code review
- Writing Great Pull Request Descriptions: https://github.blog/
