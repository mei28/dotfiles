# Claude Code × Codex 併用ガイド

Claude Code を主軸に、調査・計画は Claude Code、実装・レビューは Codex に分担する。
どちらかが利用上限に近づいたら、もう片方へ手動で切り替えて継続する。
両ツールは共有の開発標準（`.claude/AGENTS.md`）で一貫して動く。

## 役割分担

| フェーズ | 主担当 | 補助 |
|---|---|---|
| 調査 / 計画 | Claude Code（Plan mode, Explore/Plan） | Codex |
| 実装 | Codex（`codex exec` / TUI / MCP） | Claude Code |
| レビュー | Codex（`codex review`, `/codex-review`） | Claude `/code-review` |
| 引き継ぎ | `.tmp/progress.md`（共通） | — |

```
        ┌────────────────────┐  Claude→Codex (MCP / codex exec)  ┌────────────────────┐
        │   Claude Code       │ ════════════════════════════════▶ │      Codex CLI      │
        │  調査 / 計画 (主)   │                                   │  実装 / レビュー(主)│
        │  Plan / Explore     │ ◀════════════════════════════════ │  exec / review / TUI│
        └─────────┬──────────┘  Codex→Claude (mcp_servers.claude) └─────────┬──────────┘
                  └──────────────── .tmp/progress.md ─────────────────────┘
                              （上限フォールバック時の橋渡し）
```

## 構成の考え方

- **Codex 本体**: nix（`modules/codex.nix` の `pkgs.codex`）で管理。更新は `nix flake update` → `just update <host>`。
- **共有 AGENTS.md / prompts**: nix（`modules/codex.nix`）が `~/.codex/AGENTS.md` と `~/.codex/prompts` を symlink。
  これらは codex が書き込まないため symlink で安全に管理できる。
- **`~/.codex/config.toml`**: codex が `trust_level` や UI フラグを実行時に書き込むため **symlink しない**
  （`~/.claude.json` を管理しないのと同じ理由）。MCP は `codex mcp add` で、任意の既定値は手動で設定する。

## 初回セットアップ（各 mac ホストで一度）

nix が自動でやること: `~/.codex/{AGENTS.md,prompts}` の symlink、Claude の `@AGENTS.md` import 用ファイル配置。

手動でやること:

| 手順 | コマンド | 備考 |
|---|---|---|
| 1. nix 適用 | `just build babalab-mac` → `just update babalab-mac` | AGENTS.md/prompts の symlink を作る |
| 2. Codex ログイン | `codex login`（確認 `codex login status`） | ChatGPT サインイン。対話必須 |
| 3. MCP 相互登録 | `just setup-ai-mcp`（確認 `claude mcp list` / `codex mcp list`） | 両方向を冪等登録 |
| 4.（任意）既定値 | `.codex/config.toml.example` を `~/.codex/config.toml` に手動追記 | 推論強度など。スキルはフラグ指定なので必須ではない |
| 5. Claude 再起動 | — | `@AGENTS.md` import / MCP の再読込 |

## Claude → Codex（Claude 主導で実装/レビューを委譲）

Claude Code セッション内から Codex に作業を渡す。Claude のトークンも消費する点に注意
（純粋なフォールバックには使わない。下記「フォールバック運用」を参照）。

### スキルで委譲
- `/codex-implement [計画ファイル]` — 承認済みの計画を Codex に実装させ、`git diff` を要約。
- `/codex-review` — 現在の変更を Codex がレビューし、APPROVED/WARNING/BLOCKED で判定。

### 直接コマンドで委譲（手動）
```bash
# 実装（-s でサンドボックス=書込を指定。profile 不要）
codex exec -s workspace-write "Implement the plan in .tmp/plan.md. Follow ~/.codex/AGENTS.md. Do not commit."

# レビュー（専用サブコマンド。読み取り専用）
codex review --uncommitted "End with APPROVED/WARNING/BLOCKED."
#   --uncommitted: staged+unstaged+untracked / --base <branch>: ブランチ比較 / --commit <sha>: 単一コミット
```

### MCP 経由
`just setup-ai-mcp` 済みなら、Claude のセッション中に `codex` MCP ツールを直接呼べる
（`claude mcp list` で `codex … ✔ Connected` を確認）。

## Codex → Claude（Codex 主導で調査/計画を委譲）

`~/.codex/config.toml` に `[mcp_servers.claude]`（`claude mcp serve`）を登録済み。Codex 起動時に
Claude Code が MCP ツールとして見える。Codex 主役で進めつつ、込み入った調査や計画は Claude に委譲できる。

```bash
codex                 # TUI 起動。~/.codex/AGENTS.md と repo の AGENTS.md/CLAUDE.md を自動ロード
codex mcp list        # claude サーバが enabled であること
```
Codex 内の slash commands（`~/.codex/prompts/` 由来。`/` メニューに表示）:
- `/resume` — `.tmp/progress.md` と計画を読んで続行（Claude から引き継いだ時）。
- `/review` — 現在の diff を構造化レビュー。
- `/handoff` — Claude へ戻すため `.tmp/progress.md` を更新。

## フォールバック運用（上限が近づいたら切り替え）

上限が近い側のツールでは「もう片方を駆動する」ことはできない（駆動側のトークンを使うため）。
真の切り替えは、別ペインでもう片方の CLI を直接起動する。共有 `AGENTS.md` と `.tmp/progress.md` で再開が滑らか。

手順:
1. 現在のツールで引き継ぎノートを作る（Claude → `/handoff` スキル / Codex → `/handoff` プロンプト）。
2. 別ペインで反対のツールを起動。
   - Codex で再開: `codex` → `/resume`。
   - Claude で再開: `claude` 起動後、最初に `.tmp/progress.md` を読ませる。
3. 完了したら元のツールに戻る（同じく `/handoff` → 起動 → 再開）。

`.tmp/progress.md` の書式:
```
# Goal:   <達成したいこと>
# Plan:   <計画ファイルへのパス、または箇条書き>
# Done:   <完了した変更（主要ファイルパス付き）>
# Next:   <次にやること（順序付き）>
# Open:   <未解決の論点 / 要判断>
# Resume: <切替先が最初に読む/実行すべきファイル・コマンド>
```

## ファイル構成

| パス | 役割 |
|---|---|
| `.claude/AGENTS.md` | 共有開発標準（単一の真実）。Claude/Codex 双方が読む |
| `.claude/CLAUDE.md` | `@AGENTS.md` + Claude 固有のみ |
| `.claude/skills/{codex-implement,codex-review,handoff}/` | Claude 側の連携スキル |
| `.codex/prompts/{resume,review,handoff}.md` | Codex の slash commands（`~/.codex/prompts` へ symlink） |
| `.codex/config.toml.example` | `~/.codex/config.toml` への任意追記の参考（codex に読まれない） |
| `~/.codex/AGENTS.md` | `.claude/AGENTS.md` への symlink（共有） |
| `~/.codex/config.toml` | codex 所有（symlink しない）。MCP / trust / 既定値 |
| `.config/nix/home-manager/modules/codex.nix` | `pkgs.codex` + `~/.codex` の symlink を管理 |
| `justfile` の `setup-ai-mcp` | Claude↔Codex の MCP を冪等登録 |

## 既存 repo への展開

- repo ルートに `AGENTS.md`（プロジェクト標準）と `CLAUDE.md`（`@AGENTS.md` の1行 + repo 固有）を置くと、
  Codex は `AGENTS.md` を、Claude は `CLAUDE.md` を読む。
- `AGENTS.md` を置いていない repo でも、`~/.codex/config.toml` に
  `project_doc_fallback_filenames = ["CLAUDE.md"]`（`config.toml.example` 参照）を入れておけば
  Codex は `CLAUDE.md` を指示として読む。

## トラブルシュート

- `claude mcp list` に codex が出ない / connected でない
  → `just setup-ai-mcp` を再実行。`codex mcp-server --help` でサブコマンド名を確認（旧版は `codex mcp`）。
- Codex から claude が呼べない（`codex mcp list` に出ない）
  → `$HOME` から `just setup-ai-mcp`。`claude mcp serve --help` を確認し PATH に `claude` があること。
- Codex が AGENTS.md を読まない
  → `head -3 ~/.codex/AGENTS.md` が共有標準を返すか（symlink 切れの有無）を確認。`just update <host>` を再適用。
- `~/.codex/config.toml` would be clobbered（home-manager 失敗）
  → config.toml は symlink しない設計。`modules/codex.nix` に config.toml の symlink が残っていないか確認。
- 認証エラー
  → `codex login status` を確認。期限切れなら `codex login`。
