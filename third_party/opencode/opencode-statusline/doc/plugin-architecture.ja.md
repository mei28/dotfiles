# プラグインアーキテクチャ

[中文](plugin-architecture.md) | [English](plugin-architecture.en.md) | [日本語](plugin-architecture.ja.md)

`opencode-statusline` は OpenCode TUI plugin で、次の 2 つのユーザー入口を提供します。

- `/usage`：現在のモデルが使っている provider の usage/quota 情報を TUI dialog に表示します。
- `/statusline`：prompt のモデル行に追加する状態フィールドを設定します。

設計目標は、チャットコンテキストを汚染しないこと、OpenCode TUI state をできるだけ再利用すること、provider query を cache しつつ失敗に強くすること、そして OpenCode 標準 prompt layout を崩さないことです。

## パッケージ構成

```text
src/
  index.ts                 package server entry
  plugin.ts                empty server shim
  tui.tsx                  TUI slot, slash command, dialog, statusline width/rendering
  lib/
    auth.ts                env/config/auth.json credential lookup
    providers.ts           provider usage collectors and normalization
    opencode-client.ts     active model resolution and SDK compatibility helpers
    tui-usage.ts           TUI /usage text builder
    usage-format.ts        /usage report formatting
    statusline.ts          statusline field rendering
    statusline-config.ts   persisted field selection and aliases
    format.ts              shared formatting helpers
tests/
  *.test.ts                unit tests for formatting, config, model resolution, statusline output
```

`package.json` は server entry と TUI entry の両方を公開しています。OpenCode の package-based plugin loading がこの形を期待するためです。server plugin は互換性のための空 shim で、interactive features は TUI plugin 側にあります。

## TUI Entry

`src/tui.tsx` は次を登録します。

| Area | Implementation |
| --- | --- |
| 全 platform の `session_prompt` slot | `api.ui.Prompt` を wrap し、host props と `session_prompt_right` content を保持しながら prompt の `right` node に statusline fields を注入 |
| `/usage` command | `api.keymap.registerLayer`, `slashName: "usage"` |
| `/statusline` command | `api.keymap.registerLayer`, `slashName: "statusline"` |
| usage close binding | usage dialog が開いている間の dialog-layer `return` binding |

どちらの slash command も TUI command であり、server chat command ではありません。dialog を直接開くため chat message を作らず、usage/statusline data は model context に入りません。

## `/usage` Flow

1. User が `/usage` を実行します。
2. `openUsageDialog()` が loading dialog を開きます。
3. `buildTuiUsageText()` が active model と provider を解決します。
4. `collectProviderUsage(..., force: true)` が provider collector を呼びます。
5. `formatUsageReport()` が normalized report を rows に整形します。
6. `UsageDialog` が label、value、`ok` button を持つ large dialog を描画します。

session が開かれていない場合でも、`/usage` は configured model または recent model state を使おうとします。model を解決できない場合は non-fatal な "Usage unavailable" message を表示します。

reset timestamp は local time の固定幅 `YYYY-MM-DD HH:mm:ss` 形式で表示し、provider 間で月/日/時刻の桁がそろうようにします。

## `/statusline` Flow

1. User が `/statusline` を実行します。
2. `StatuslineDialog` が `STATUSLINE_FIELDS` の `DialogSelect` list を表示します。
3. item を選ぶと current field array で toggle されます。
4. selection order は保持され、表示順になります。
5. `saveStatuslineConfig()` で config を保存します。
6. `notifyConfigChanged()` が statusline refresh を起こします。

保存される config の形：

```json
{
  "version": 1,
  "fields": ["repo", "branch", "context_window", "quota_5h"]
}
```

default path：

```text
${XDG_DATA_HOME:-~/.local/share}/opencode/statusline-plugin.json
```

`OPENCODE_STATUSLINE_CONFIG` で上書きできます。

## Statusline Rendering

Statusline fields は `src/lib/statusline.ts` で構築されます。

対応フィールド：

| Field id | Display |
| --- | --- |
| `repo` | repository/worktree basename |
| `branch` | current git branch。`git` prefix は付けません |
| `git_diff_stats` | tracked staged+unstaged git diff line counts as `+123,-45` |
| `context_used` | latest token-bearing assistant message token total |
| `context_remaining` | model context limit から current context estimate を引いた値 |
| `context_length` | current model context limit |
| `context_window` | used/total context window |
| `generation_metrics` | approximate TTFT and output token generation speed |
| `subagent_status` | active parent/child subagent state |
| `agent_status` | main session status。`agent` prefix は付けません。一時的な `queued`/`pending` は省略します |
| `quota_5h` | provider 5h quota used percent |
| `quota_weekly` | provider weekly quota used percent |
| `provider_balance` | provider balance または remaining limit as `bal $12.34` |
| `session_io` | session input/output tokens as `<input> in / <output> out` |
| `session_total` | session total tokens as `<total> used` |
| `session_cost` | session cost as `cost $0.02`、または equivalent estimate as `eq $0.02` |

利用できない値は省略されます。たとえば OpenRouter は balance/usage data を持ちますが 5h subscription quota window はないため、`quota_5h` は描画されません。child sessions が idle または completed の場合、active subagent なしとして扱い、`subagent_status` は省略します。

`provider_balance` は `/usage` と同じ normalized rows である `UsageReport.balances` を再利用します。`remaining` を含む label を優先し、次に `balance`、`credit` を優先します。numeric な money-like value だけを描画します。balance row がない純粋な subscription quota provider では field を省略します。

`git_diff_stats` は field が選択されている場合だけ `git diff HEAD --no-ext-diff --numstat --` を使います。staged と unstaged の両方を持つ file でも各 change を一度だけ数え、binary rows と untracked files は除外します。結果は短時間 cache し、`session.updated` で clear します。

`session_io`、`session_total`、`session_cost` は、OpenCode が公開する descendant-session messages を含めます。探索は cycle-safe で、24 sessions、4 levels、1 秒、同時 SDK calls 4 件に制限されます。`session_total` は explicit total token value を優先し、ない場合は input、output、reasoning、cache tokens を合計します。

`session_cost` は OpenCode が assistant message に記録した cost を優先します。recorded cost がない場合、現在の object-shaped model pricing、context tiers、input/output/reasoning/cache token counts から equivalent cost を推定します。`eq $...` は必ずしも実際の billing ではありません。

`generation_metrics` は approximate です。TTFT は assistant creation から最初の text/reasoning part までです。generation speed は text/reasoning intervals の union に対する output + reasoning tokens で計算し、tool execution timestamps は除外します。tool-only message では metric を表示しません。

TUI rendering は colored segments を使います：

- repo: normal text
- branch: info
- git diff stats: warning
- context: accent/success/secondary
- generation metrics: info
- agent/subagent: primary
- quota: warning
- provider balance: success
- session token totals: secondary
- session cost: success
- separators and truncation marker: muted

## Prompt Width Strategy

Prompt integration は全 platform で同じ precompiled OpenTUI 0.4 path を使います。plugin は `session_prompt` を wrap し、元の `session_prompt_right` slot を prompt の `right` node 内に保持します。

plugin は次と共存する必要があります。

- OpenCode の left-side agent/model/provider labels
- OpenCode の既存 prompt 右側コンテンツ
- 他 plugin の `session_prompt_right` slot content
- terminal width changes
- optional OpenCode sidebar width

`PromptRightContent` は `onSizeChange` で元の right slot width を測定します。`StatuslineView` は host の `auto` label と最新 model variant も予約し、次の budget を計算します。

```text
estimated prompt inner width
- estimated native left model row width
- measured native right-side prompt width
- row gaps and safety columns
```

残り幅が最小閾値より小さい場合、statusline output は非表示になります。それ以外の場合は terminal column width によって text を truncate し、fixed-width segments として描画します。これにより prompt が次の行へ折り返すのを避けます。

## Active Model Resolution

Active model resolution は `src/lib/opencode-client.ts` に集約されています。

入力元：

| Source | Notes |
| --- | --- |
| command model | server-style caller が明示した場合に使用 |
| OpenCode config model | `config.model`。通常は `<provider>/<model>` |
| recent TUI model state | `${XDG_STATE_HOME:-~/.local/state}/opencode/model.json` |
| session model | `session.model.providerID` / `session.model.modelID` |
| latest message model | recent messages からの fallback |

recent model state は TUI 内で model switch した後に役立ちます。TUI が提供する `api.state.path.state` を authoritative path とし、environment/XDG は fallback にだけ使います。statusline は local `model.json` signature を 2 秒ごとに poll し、必要な fields がある場合だけ provider を query します。

state directory は `OPENCODE_STATUSLINE_STATE_DIR` で上書きできます。

## Refresh Model

Statusline は次で refresh されます。

| Trigger | Behavior |
| --- | --- |
| `/statusline` field selection change | 150ms と 600ms に queued reload |
| `session.updated` | current session を 150ms と 600ms に queued reload |
| `message.updated` / `message.removed` | token/context 関連 fields を 150ms と 600ms に queued reload |
| `tui.session.select` | active session が変わったとき 150ms と 600ms に queued reload |
| `session.sidebar.toggle` command | layout budget を再計算 |
| recent model state file signature change | local model switch detection 後に reload |
| 60 second interval | full fallback refresh |

Streaming の `message.part.updated` と `message.part.delta` events は full statusline rebuild を起こしません。次の `message.updated` または session event で最終 token/context data を refresh します。

Provider quota collection は credential-scoped の 60 秒 fresh cache と 10 分 stale cache を持ちます。network deadline は response headers と body parsing の両方を対象にし、statusline はさらに 2.5 秒の outer deadline を使います。同じ account の並行 refresh は一つの request を共有します。`/usage` は fresh data を取得し、閉じた dialog や新しい request に古い result を適用しません。

## Context Hygiene

plugin は次の方法で context pollution を避けます。

- `/usage` と `/statusline` を TUI keymap slash commands として登録
- usage data を chat message ではなく TUI dialogs に表示
- statusline data を prompt UI のみに保持
- server-side command injection を使わない

package は package-based plugin loading 互換のため、空 shim の server entry も含みます。

## Provider Layer

Provider collectors は `src/lib/providers.ts` にあります。各 collector は：

1. credentials を解決
2. provider endpoint を query
3. provider-specific data を `UsageReport` に変換
4. UI caller に throw せず error report を返す

詳細な provider endpoints と response mappings は [provider-query-methods.ja.md](./provider-query-methods.ja.md) に記載しています。

## Known Limits

- OpenCode は local TUI state のすべてを plugin API で公開していないため、model switch detection は一部 local recent model state に依存します。
- OpenAI OAuth token は読み取りますが、この plugin では refresh しません。
- Provider quota fields は provider が公開している windows だけを描画します。
