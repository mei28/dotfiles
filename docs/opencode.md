# opencode 運用ガイド

Claude Code が使えないときのフォールバック主軸。GLM / Kimi を自前のローカルサーバで回す。
skills と開発標準は Claude Code / Codex と同じものを共有し、herdr と Clawd on Desk の
連携もそのまま効く。

対象ホストは sbi-mac と babalab-mac の 2 台。Linux ホスト（qia-aws, sbi-superpod）には
入れていない。

## 位置づけ

| 状況 | 使うツール |
|---|---|
| 通常 | Claude Code（調査 / 計画 / 評価）+ Codex（実装 / レビュー） |
| Claude Code が上限や障害で使えない | opencode が主軸を引き継ぐ |

役割の一部を切り出すのではなく、セッションごと引き継ぐ点が Codex や Antigravity への
委譲と違う。引き継ぎは他ツールと同じく `.tmp/progress.md`（`handoff` skill）を使う。

Anthropic の Pro / Max サブスクは opencode から使えない。opencode 側が 2026-03 に
Anthropic OAuth を削除し、Anthropic も規約で第三者ツールでのサブスク OAuth を禁止した。
Claude モデルを opencode で回すには API キー課金が要る。だから opencode は Claude の
代替ではなく、別プロバイダの窓口として置いている。

## 構成の考え方

- 本体: nix（`modules/opencode.nix` の `pkgs.opencode`）で管理する。
  更新は `nix flake update` から `just update <host>` で適用する。
- `autoupdate` は `false` 固定。nix store は読み取り専用で、自己更新が走ると失敗する。
- 設定ディレクトリ: `~/.config/opencode` を丸ごと symlink する。
  認証情報は `~/.local/share/opencode/auth.json` に分離されるため、丸ごと貼っても
  repo に秘密が入らない。codex の `config.toml` を symlink できないのとは事情が違う。
- 共有 `AGENTS.md`: `.config/opencode/AGENTS.md` を `.claude/AGENTS.md` への相対 symlink
  にしてある。opencode の global ルール探索は `~/.config/opencode/AGENTS.md` を見る。
  `~/.claude/CLAUDE.md` へのフォールバックもあるが、そちらは `@AGENTS.md` の import しか
  書いておらず、opencode は `@` import を展開しないため共有標準が丸ごと落ちる。
- skills: opencode は `~/.claude/skills` をネイティブに探索する。移設もコピーも要らない。

## 初回セットアップ（各 mac ホストで一度）

nix が自動でやること: `pkgs.opencode` の導入と `~/.config/opencode` の symlink。

手動でやること:

| 手順 | コマンド | 備考 |
|---|---|---|
| 1. nix 適用 | `just build <host>` → `just update <host>` | 本体と設定 symlink |
| 2. herdr 連携 | `herdr integration install opencode` | `~/.config/opencode/plugins/herdr-agent-state.js` を置く。状態がサイドバーに出る |
| 3. Clawd 連携 | Clawd on Desk 側で opencode を有効化 | opencode は権限承認をバブルで出せる数少ないエージェントの 1 つ |
| 4. プロバイダ登録 | `opencode auth login` | 自前サーバの API キーを登録。対話必須 |
| 5. モデル設定 | `.config/opencode/opencode.json` に `provider` と `model` を記入 | ファイル内のコメントに雛形あり |

`opencode auth login` の認証情報は `~/.local/share/opencode/auth.json` に入る。
repo には入らないので、ホストごとに 1 回ずつ実行する。

## 資産の引き継ぎ状況

| 資産 | 状況 |
|---|---|
| skills | そのまま。`~/.claude/skills` をネイティブ探索。frontmatter も互換 |
| AGENTS.md | symlink 経由で共有 |
| herdr | 公式連携あり（`herdr integration install opencode`） |
| Clawd on Desk | 公式サポートあり。承認バブルも対応 |
| Codex への委譲 | `codex-implement` / `codex-review` は `codex exec` を叩くだけなので無改造で動く |
| statusline | 持たない。組み込みフッターが context 使用率とコストを出す |
| WezTerm のタブ状態表示 | 移植しない。下記の制約を参照 |
| hooks | 無い。プラグイン方式（`tool.execute.before/after`, `session.*`） |
| `.claude/agents`, `.claude/commands` | 互換なし。opencode 側は `~/.config/opencode/{agents,commands}` |

## キーバインド

leader は `ctrl+x`。`tui.json` で変更できる。既定から変えているのは 1 点だけ。

`ctrl+d` が `app_exit` / `session_delete` / `input_delete` に三重登録されており、入力欄が
空のときに押すと opencode ごと終了する。これを分離してある。

入力欄は readline 系で、Claude Code の `editorMode: "normal"` に相当するモード状態が無い。
`keybinds.input_*` は単発アクションの集合で、NORMAL / INSERT という概念自体が無いため、
vim 風の再マップは中途半端にしかならない。長文は `<leader>e`（`ctrl+x` → `e`）で
`$EDITOR` を開いて書く。

## 既知の制約

- Anthropic の Pro / Max サブスクは使えない（上記「位置づけ」を参照）
- statusline のフックが無い。feature request は open だが未実装
- hooks が無いので、`.claude/hooks/wezterm-state.sh` 相当は移植していない。
  opencode の TUI は stdout を占有しており、プラグインから OSC を撃つと描画を壊す。
  そもそもあの仕組みは WezTerm のタブに 1 対 1 で対応する設計で、herdr の中では
  「1 タブ = herdr 全体」になって意図通りに働かない
- herdr の中では `ctrl+b` が herdr の prefix に食われる。opencode の `input_move_left` は
  矢印キーでも動くので実害は小さい
- `.mcp.json` 互換が無い。MCP を使うなら `opencode.json` の `mcp` キーに書き直す

## 更新

```bash
nix flake update
just build <host>
just update <host>
```

`autoupdate` を有効にしてはいけない。nix store が読み取り専用なので失敗する。
