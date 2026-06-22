# Claude Code × Codex 連携ガイド

Claude Code を主軸に、調査と計画は Claude Code、実装とレビューは Codex に分担する。
Gemini CLI も同じ枠組みで使える（詳細は `docs/gemini.md`）。
どちらかが利用上限に近づいたら、別のツールへ手動で切り替えて継続する。
全ツールは共有の開発標準（`.claude/AGENTS.md`）で一貫して動く。

## 役割分担

| フェーズ | 主担当 | 補助 |
|---|---|---|
| 調査 / 計画 / 評価 | Claude Code（Plan mode, Explore/Plan） | Codex, Gemini |
| 実装 | Codex（`codex exec` / TUI / MCP） | Gemini, Claude Code |
| レビュー | Codex + Gemini + Claude（三者） | — |
| 引き継ぎ | `.tmp/progress.md`（三ツール共通） | — |

```
        ┌────────────────────┐  Claude→Codex (MCP / codex exec)  ┌────────────────────┐
        │   Claude Code       │ ════════════════════════════════▶ │      Codex CLI      │
        │  調査 / 計画 (主)   │                                   │  実装 / レビュー(主)│
        │  Plan / Explore     │ ◀════════════════════════════════ │  exec / review / TUI│
        └─────────┬──────────┘  Codex→Claude (mcp_servers.claude) └─────────┬──────────┘
                  └──────────────── .tmp/progress.md ─────────────────────┘
                              （上限フォールバック時の橋渡し。Gemini も同じノートで再開可）
```

## 構成の考え方

- Codex 本体: nix（`modules/codex.nix` の `pkgs.codex`）で管理する。
  更新は `nix flake update` から `just update <host>` で適用する。
- 共有 `AGENTS.md` / prompts: nix（`modules/codex.nix`）が `~/.codex/AGENTS.md` と `~/.codex/prompts` を symlink する。
  これらは codex が書き込まないため symlink で管理できる。
- 共有 profile v2: `.codex/shared.config.toml` を `~/.codex/shared.config.toml` へ symlink する。
  この profile は `codex -p shared` で有効化する。
  codex は profile ファイルへ書き込まないため、dotfiles の宣言的な既定値を置ける。
- base `~/.codex/config.toml`: symlink しない。
  codex が `trust_level` / `nux` / `model` / `mcp_servers` / `tui` などを実行時に書き込むため、codex 所有の runtime 状態として残す。
  `shared` を通常の既定にしたい場合は、TUI settings で active profile に `shared` を一度選ぶ。
  その永続化は base config 側に codex が書き込む。

## 初回セットアップ（各 mac ホストで一度）

nix が自動でやること: `~/.codex/{AGENTS.md,prompts,shared.config.toml}` の symlink、Claude の `@AGENTS.md` import 用ファイル配置。

手動でやること:

| 手順 | コマンド | 備考 |
|---|---|---|
| 1. nix 適用 | `just build babalab-mac` → `just update babalab-mac` | AGENTS.md / prompts / shared profile の symlink を作る |
| 2. Codex ログイン | `codex login`（確認 `codex login status`） | ChatGPT サインイン。対話必須 |
| 3. MCP 相互登録 | `just setup-ai-mcp`（確認 `claude mcp list` / `codex mcp list`） | 両方向を冪等登録 |
| 4.（任意）profile 既定化 | `codex -p shared` → TUI settings | active profile に `shared` を一度選ぶと `-p shared` を省略できる |
| 5. Claude 再起動 | なし | `@AGENTS.md` import と MCP を再読込する |

`.codex/config.toml.example` は base config の役割を説明する参照資料であり、codex には読み込まれない。
宣言的な既定値は `.codex/shared.config.toml` に置く。

## 承認と進捗の可視化（3レーン）

| レーン | 用途 | 起動 | 承認 | 進捗 |
|---|---|---|---|---|
| 監督 | 人間が操作を見て承認する作業 | `codex -p shared -a on-request` | TUI only | status_line ライブ |
| 信頼済み自動実行 | 承認済み計画を非対話で実装する作業 | `codex exec -p shared -c approval_policy=never --json ...` | 承認待ちを作らない | background + Monitor で `--json` を見る |
| 結果だけ | 短時間の委譲で最終結果だけ要る作業 | MCP `codex`（`approval-policy: never`） | 承認を使わない | 最終応答のみ |

MCP `codex` は `approval-policy` と `sandbox` を持ち、承認を MCP elicitation として転送する設計になっている。
Claude Code 2.1.183 は elicitation に対応している。
しかし Codex の未修正バグ [#18268](https://github.com/openai/codex/issues/18268)（OPEN）により、仕様に沿った承認応答が Codex server 側で Denied として扱われる。
そのため、信頼できる人間承認は TUI に限定する。
自動実行レーンでは `approval_policy=never` を明示し、承認待ちで止まらないようにする。

Claude が監督レーンに作業を振る場合は、ユーザーが別ペインへ貼り付けられる起動コマンドを提示する。
起動後は `/resume` で `.tmp/progress.md` から再開し、Claude へ戻す前に `/handoff` で `.tmp/progress.md` を更新する。

```bash
codex -p shared -a on-request
# 起動後: /resume
# Claude へ戻す前: /handoff
```

## Claude → Codex（Claude 主導で実装/レビューを委譲）

Claude Code セッション内から Codex に作業を渡す。
Claude のトークンも消費する点に注意する。
純粋なフォールバックでは、下記「フォールバック運用」のように別ペインで Codex を直接起動する。

### スキルで委譲

- `/codex-implement [計画ファイル]`: 承認済みの計画を Codex に実装させ、`git diff` を要約する。
- `/codex-review`: 現在の変更を Codex がレビューし、APPROVED / WARNING / BLOCKED で判定する。

### 直接コマンドで委譲（手動）

```bash
# 信頼済み自動実行。Claude Code 側では run_in_background と Monitor を併用する。
codex exec -p shared -c approval_policy=never --json -o .tmp/codex-exec.jsonl "Implement the plan in .tmp/plan.md. Follow ~/.codex/AGENTS.md. Do not commit."

# 監督レーン。別ペインで起動し、TUI の承認を使う。
codex -p shared -a on-request
# 起動後: /resume

# レビュー。専用サブコマンドは read-only。
codex review --uncommitted "End with APPROVED/WARNING/BLOCKED."
#   --uncommitted: staged + unstaged + untracked
#   --base <branch>: ブランチ比較
#   --commit <sha>: 単一コミット
```

### MCP 経由

`just setup-ai-mcp` 済みなら、Claude のセッション中に `codex` MCP ツールを直接呼べる。
`claude mcp list` で `codex ... Connected` を確認する。
ただし MCP 経由は最終応答だけが戻る。
人間承認は #18268 のため現状の運用対象にしない。
使う場合は `approval-policy: never` を指定し、短時間の「結果だけ」レーンに限定する。

### 進捗の確認

- `codex exec --json` は Claude Code から `run_in_background` で起動し、Monitor で JSON ストリームを見る。
- `-o <file>` を付けると結果をファイルへ残せる。
  `.tmp/codex-exec.jsonl` のように `.tmp` 配下へ置く。
- 非対話実行の続きを確認する場合は `codex exec resume --last` を使う。
- TUI セッションの続きを開く場合は `codex resume --last` を使う。

## Codex → Claude（Codex 主導で調査/計画を委譲）

base `~/.codex/config.toml` に `[mcp_servers.claude]`（`claude mcp serve`）を登録済みにする。
Codex 起動時に Claude Code が MCP ツールとして見える。
Codex 主役で進めつつ、込み入った調査や計画は Claude に委譲できる。

```bash
codex -p shared        # TUI 起動。~/.codex/AGENTS.md と repo の AGENTS.md / CLAUDE.md を自動ロード
codex mcp list         # claude サーバが enabled であること
```

Codex 内の slash commands（`~/.codex/prompts/` 由来。`/` メニューに表示）:

- `/resume`: `.tmp/progress.md` と計画を読んで続行する。
- `/review`: 現在の diff を構造化レビューする。
- `/handoff`: Claude へ戻すため `.tmp/progress.md` を更新する。

## フォールバック運用（上限が近づいたら切り替え）

上限が近い側のツールでは「もう片方を駆動する」ことはできない。
駆動側のトークンを使うためだ。
真の切り替えは、別ペインでもう片方の CLI を直接起動する。
共有 `AGENTS.md` と `.tmp/progress.md` で再開する。

手順:

1. 現在のツールで引き継ぎノートを作る（Claude → `/handoff` スキル / Codex → `/handoff` プロンプト）。
2. 別ペインで反対のツールを起動する。
   - Codex で再開: `codex -p shared` → `/resume`。
   - 監督と承認が要る場合: `codex -p shared -a on-request` → `/resume`。
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
| `.claude/AGENTS.md` | 共有開発標準（単一の真実）。全 AI ツールが読む |
| `.claude/CLAUDE.md` | `@AGENTS.md` + Claude 固有のみ |
| `GEMINI.md` | Gemini CLI のプロジェクト指示（ルートで自動読込） |
| `.claude/skills/{codex-implement,codex-review}/` | Claude から Codex へ委譲するスキル |
| `.claude/skills/{antigravity-implement,antigravity-review}/` | Claude から Antigravity CLI へ委譲するスキル |
| `.claude/skills/handoff/` | 引き継ぎノート作成スキル（三ツール共通） |
| `.codex/prompts/{resume,review,handoff}.md` | Codex の slash commands（`~/.codex/prompts` へ symlink） |
| `.codex/shared.config.toml` | symlink 管理する Codex profile v2。`codex -p shared` で有効化 |
| `.codex/config.toml.example` | base config の役割メモ。codex には読み込まれない |
| `~/.codex/AGENTS.md` | `.claude/AGENTS.md` への symlink（共有） |
| `~/.codex/shared.config.toml` | `.codex/shared.config.toml` への symlink（共有 profile） |
| `~/.codex/config.toml` | codex 所有。symlink しない。trust / nux / model / MCP / tui の runtime 状態 |
| `.config/nix/home-manager/modules/codex.nix` | `pkgs.codex` + `~/.codex` の symlink を管理 |
| `justfile` の `setup-ai-mcp` | Claude↔Codex の MCP を冪等登録 |
| `docs/antigravity.md` | Antigravity CLI 連携ガイド |

## 既存 repo への展開

repo ルートに `AGENTS.md`（プロジェクト標準）と `CLAUDE.md`（`@AGENTS.md` の1行 + repo 固有）を置くと、Codex は `AGENTS.md` を、Claude は `CLAUDE.md` を読む。
`AGENTS.md` を置いていない repo でも、`codex -p shared` なら `project_doc_fallback_filenames = ["CLAUDE.md"]` が効く。
Codex は `CLAUDE.md` を指示ファイルとして読む。

## トラブルシュート

- `claude mcp list` に codex が出ない / connected でない
  → `just setup-ai-mcp` を再実行する。
  `codex mcp-server --help` でサブコマンド名を確認する（旧版は `codex mcp`）。
- Codex から claude が呼べない（`codex mcp list` に出ない）
  → `$HOME` から `just setup-ai-mcp` を実行する。
  `claude mcp serve --help` を確認し、PATH に `claude` があることを確認する。
- Codex が AGENTS.md を読まない
  → `head -3 ~/.codex/AGENTS.md` が共有標準を返すか確認する。
  symlink 切れなら `just update <host>` を再適用する。
- `~/.codex/config.toml` would be clobbered（home-manager 失敗）
  → config.toml は symlink しない設計。
  `modules/codex.nix` に config.toml の symlink が残っていないか確認する。
- 昇格拒否で停止
  → MCP `codex` の人間承認は [#18268](https://github.com/openai/codex/issues/18268) と非対話設計のため止まりやすい。
  人間承認が必要なら TUI の `codex -p shared -a on-request` へ回す。
  自動実行なら `codex exec -p shared -c approval_policy=never --json ...` を使う。
  将来の codex release で #18268 が修正されたら、`approval_policy=never` の強制と TUI ルーティングを緩める。
- サンドボックス初期化エラー
  → 承認ではなく OS サンドボックス（Linux Landlock など）の初期化失敗として扱う。
  すでに隔離された環境では `-s danger-full-access` か `--dangerously-bypass-approvals-and-sandbox` を使う。
- Codex が `.codex/` 配下に書けない（`Operation not permitted`）
  → Codex の `workspace-write` サンドボックスは、dotfiles 内であっても `.codex/` 配下への書き込みを拒否する（自分の設定ディレクトリ名を保護するため）。
  `.codex/shared.config.toml` などを編集させるには `-s danger-full-access` で実行するか、Claude/手動で書く。
- 認証エラー
  → `codex login status` を確認する。
  期限切れなら `codex login` を実行する。
