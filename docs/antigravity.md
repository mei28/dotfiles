# Antigravity CLI 連携ガイド

Claude Code をオーケストレーターとして、Antigravity CLI (`agy`) に実装・レビューを委譲する。
Antigravity は Claude Code / Codex と同格の実行エージェントであり、どれかが上限に近づいたら別のツールが引き継げる。

> **経緯**: Google Gemini CLI は 2026-06-18 に個人向け（Google AI Pro 含む）を停止した。
> Antigravity CLI がその後継。コマンドは `gemini` → `agy`。
> プロジェクト指示ファイル `GEMINI.md` はそのまま使用可能（Antigravity が読む）。

## 三ツールの役割

| フェーズ | 主担当 | 補助 |
|---|---|---|
| 調査 / 計画 / 評価 | Claude Code | — |
| 実装 | Codex（主）、Antigravity（副） | Claude Code |
| レビュー | Claude + Codex + Antigravity（三者） | — |
| フォールバック | 残り二ツール | 上限に近いツールを迂回 |

Claude は Codex / Antigravity の出力を **受け取り → 評価 → 採否判断** する。盲目的には受け入れない。

```
        ┌────────────────────┐
        │   Claude Code       │  指示・評価
        │  調査 / 計画 (主)   │
        └─────────┬──────────┘
                  │
        ┌─────────┴──────────┐
        │                    │
        ▼                    ▼
┌──────────────┐    ┌──────────────────┐
│   Codex CLI  │    │  Antigravity CLI  │
│  実装 (主)   │    │  実装 (副)        │
│  レビュー    │    │  レビュー         │
└──────────────┘    └──────────────────┘
        │                    │
        └─────────┬──────────┘
                  ▼
          .tmp/progress.md
         （フォールバック橋渡し）
```

## セットアップ

### インストール

```bash
# curl スクリプト経由（npm ではない）
curl -fsSL https://antigravity.google/cli/install.sh | bash

# インストール確認
agy --version
```

nixpkgs への収録は未確定。現時点では手動インストール。収録されたら `modules/antigravity.nix` で管理する。

### 認証

```bash
agy   # 初回起動で Google アカウント認証フロー（ブラウザが開く）
```

Google AI Pro サブスクリプションで認証する。

### プロジェクト指示

`GEMINI.md`（dotfiles ルート）が Antigravity CLI にプロジェクト標準を伝える。
Antigravity は `GEMINI.md` を読む（AGENTS.md より優先される）。
開発標準の単一の真実は `.claude/AGENTS.md` にあり、`GEMINI.md` がその要点を記載している。

## 承認レーン

| レーン | 用途 | 起動 | 承認 |
|---|---|---|---|
| 自動実行 | 承認済みの計画を自律実行 | `agy --headless --approve all -p "..."` | 全ツール呼び出しを自動承認 |
| 対話 | 手動で確認しながら進める | `agy` | ユーザーが都度承認 |

`--headless --approve all` は Codex の `approval_policy=never` に相当する。
自動実行時も OS レベルのサンドボックス（macOS: `sandbox-exec`）が有効なため、任意コード実行のリスクは低い。

herdr内での自動化（`codex-implement`のherdrレーン、`docs/claude-codex.md`参照）はAntigravityには適用しない。
herdrの公式対応エージェント一覧に`agy`は含まれておらず、`agent_status`の検出が機能するかは未検証のため、動かない可能性があるレシピを文書化するリスクがある。
検証が取れるまで、Antigravityは本ガイド記載の手動運用（対話`agy`）のみとする。

## Claude → Antigravity（Claude 主導で実装 / レビューを委譲）

### スキルで委譲

- `/antigravity-implement [計画ファイル]`: 計画を Antigravity に実装させ、`git diff` を評価する。
- `/antigravity-review`: 現在の変更を Antigravity がレビューし、APPROVED / WARNING / BLOCKED で判定する。

### 直接コマンドで委譲（手動）

```bash
# 自動実行（計画ファイルを渡す）
agy --headless --approve all -p "Implement the plan in .tmp/plan.md. Follow .claude/AGENTS.md. Do not commit."

# レビュー（read-only。--headless は付けない）
agy -p "Review this diff. Per-issue: file:line, severity, problem, fix. End with APPROVED/WARNING/BLOCKED.

$(git diff HEAD)"

# 大きなコンテキストを活かしたレビュー（ファイル全体を添付）
agy -p "Review this diff in context of the full file.

Diff:
$(git diff HEAD -- path/to/file)

Full file:
$(cat path/to/file)"
```

## フォールバック運用（上限が近づいたら切り替え）

三ツールはすべて `.claude/AGENTS.md` と `.tmp/progress.md` を共有するため、どのツールからでも再開できる。

手順:

1. 現在のツールで `/handoff`（Claude / Codex）または同等の引き継ぎノートを作る。
2. 別ペインで別のツールを起動して `.tmp/progress.md` を読ませる。
   - Claude で再開: `claude` 起動後に `.tmp/progress.md` を読ませる
   - Codex で再開: `codex -p shared` → `/resume`
   - Antigravity で再開: `agy` 起動後に `.tmp/progress.md` を読ませる
3. 完了後、元のツールに戻る。

## Antigravity の強み

- **大きなコンテキスト窓**: ファイル全体を diff と一緒に渡せる。Codex review が見落とすコンテキストを補える。
- **異なるモデル**: Claude / Codex と異なる盲点を持つ。三者でレビューすると見落としが減る。
- **並列サブエージェント**: 複数のタスクを並列実行できる（Gemini CLI にはなかった機能）。

## ファイル構成

| パス | 役割 |
|---|---|
| `GEMINI.md` | Antigravity CLI のプロジェクト指示（プロジェクトルートで自動読込） |
| `.claude/AGENTS.md` | 全ツール共有の開発標準（単一の真実） |
| `.claude/skills/antigravity-review/` | Claude から Antigravity レビューを呼ぶスキル |
| `.claude/skills/antigravity-implement/` | Claude から Antigravity 実装を委譲するスキル |
| `.tmp/progress.md` | ツール間の引き継ぎノート（三ツール共通） |

## トラブルシュート

- `agy: command not found`
  → `curl -fsSL https://antigravity.google/cli/install.sh | bash` を実行する。シェルを再起動して PATH を更新する。
- 認証エラー
  → `agy` をインタラクティブに起動して再認証する。Google AI Pro の有効期限を確認する。
- `--headless --approve all` で予期しないファイルが変更された
  → `git checkout -- .` で差し戻す。計画をより具体的に書き直してから再実行する。
- Antigravity が GEMINI.md を読んでいない
  → プロジェクトルート（`GEMINI.md` があるディレクトリ）から `agy` を起動しているか確認する。
