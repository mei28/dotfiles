# 插件架构设计

[中文](plugin-architecture.md) | [English](plugin-architecture.en.md) | [日本語](plugin-architecture.ja.md)

`opencode-statusline` 是一个 OpenCode TUI 插件，提供两个用户入口：

- `/usage`：在 TUI dialog 中显示当前模型所属 provider 的 usage/quota 信息。
- `/statusline`：配置 prompt 模型行右侧追加显示的状态字段。

设计目标是：不污染聊天上下文、尽量复用 OpenCode TUI 状态、provider 查询可缓存且可失败、statusline 不挤坏 OpenCode 原生 prompt 布局。

## 包结构

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

`package.json` exposes both server and TUI entries because OpenCode plugin loading expects the package shape. The server plugin is intentionally empty; interactive features live in the TUI plugin.

## TUI Entry

`src/tui.tsx` registers:

| Area | Implementation |
| --- | --- |
| `session_prompt` slot on all platforms | Wraps `api.ui.Prompt`, preserves host props, injects statusline fields into the prompt `right` node, and retains `session_prompt_right` content |
| `/usage` command | `api.keymap.registerLayer`, `slashName: "usage"` |
| `/statusline` command | `api.keymap.registerLayer`, `slashName: "statusline"` |
| usage close binding | Dialog-layer `return` binding while the usage dialog is open |

Both slash commands are TUI commands, not server chat commands. They open dialogs directly and do not create chat messages, which keeps usage/statusline data out of model context.

## `/usage` Flow

1. User runs `/usage`.
2. `openUsageDialog()` opens a loading dialog.
3. `buildTuiUsageText()` resolves the active model and provider.
4. `collectProviderUsage(..., force: true)` queries the provider collector.
5. `formatUsageReport()` formats the normalized report into rows.
6. `UsageDialog` renders a large dialog with labels, values, and an `ok` button.

If no session is open, `/usage` still attempts to use configured or recent model state. If the model cannot be resolved, it shows a non-fatal "Usage unavailable" message.

Reset timestamps are formatted in local time as fixed-width `YYYY-MM-DD HH:mm:ss` strings so month/day/time fields align across providers.

## `/statusline` Flow

1. User runs `/statusline`.
2. `StatuslineDialog` shows a `DialogSelect` list of `STATUSLINE_FIELDS`.
3. Selecting an item toggles it in the current field array.
4. Selection order is preserved and determines display order.
5. Config is saved with `saveStatuslineConfig()`.
6. `notifyConfigChanged()` triggers statusline refresh.

Persisted config shape:

```json
{
  "version": 1,
  "fields": ["repo", "branch", "context_window", "quota_5h"]
}
```

Default path:

```text
${XDG_DATA_HOME:-~/.local/share}/opencode/statusline-plugin.json
```

Override with `OPENCODE_STATUSLINE_CONFIG`.

## Statusline Rendering

Statusline fields are built in `src/lib/statusline.ts`.

Supported fields:

| Field id | Display |
| --- | --- |
| `repo` | repository/worktree basename |
| `branch` | current git branch, without a `git` prefix |
| `git_diff_stats` | tracked staged+unstaged git diff line counts as `+123,-45` |
| `context_used` | latest token-bearing assistant message token total |
| `context_remaining` | model context limit minus current context estimate |
| `context_length` | current model context limit |
| `context_window` | used/total context window |
| `generation_metrics` | approximate TTFT and output token generation speed |
| `subagent_status` | active parent/child subagent state |
| `agent_status` | main session status without an `agent` prefix; transient `queued`/`pending` is omitted |
| `quota_5h` | provider 5h quota used percent |
| `quota_weekly` | provider weekly quota used percent |
| `provider_balance` | provider balance or remaining limit as `bal $12.34` |
| `session_io` | session input/output tokens as `<input> in / <output> out` |
| `session_total` | session total tokens as `<total> used` |
| `session_cost` | session cost as `cost $0.02` or equivalent estimate as `eq $0.02` |

Unavailable values are omitted. For example, OpenRouter has balance/usage data but no 5h subscription quota window, so `quota_5h` does not render for OpenRouter. Child sessions that are idle or completed are treated as no active subagent, so `subagent_status` is omitted in that state.

`provider_balance` reuses `UsageReport.balances`, the same normalized rows shown by `/usage`. It prefers labels containing `remaining`, then `balance`, then `credit`, and renders only numeric money-like values. Pure subscription quota providers with no balance row omit the field.

`git_diff_stats` uses `git diff HEAD --no-ext-diff --numstat --` only when the field is selected. This counts each tracked change once even when a file has both staged and unstaged edits, skips binary rows, and excludes untracked files. Results are cached briefly; `session.updated` clears the cache.

`session_io`, `session_total`, and `session_cost` include descendant-session messages when OpenCode exposes them. Discovery is cycle-safe and bounded to 24 sessions, four levels, one second, and four concurrent SDK calls. `session_total` uses OpenCode's explicit total token value when present; otherwise it sums input, output, reasoning, and cache tokens.

`session_cost` prefers OpenCode's recorded assistant message cost. If recorded cost is absent, it estimates an equivalent cost from current object-shaped model pricing, context tiers, and input/output/reasoning/cache token counts. This is useful for subscription or coding-plan providers, but `eq $...` is not necessarily actual billing.

`generation_metrics` is approximate because OpenCode exposes message and part timestamps rather than provider-native timing. TTFT runs from assistant creation to the first text/reasoning part. Generation speed uses output plus reasoning tokens over the union of text/reasoning intervals; tool execution timestamps are excluded and tool-only messages do not produce a metric.

TUI rendering uses colored segments:

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

Prompt integration uses the same precompiled OpenTUI 0.4 path on every platform. The plugin wraps `session_prompt` and keeps the original `session_prompt_right` slot inside the prompt `right` node.

The plugin must coexist with:

- OpenCode's left-side agent/model/provider labels
- OpenCode's existing right-side prompt content
- other `session_prompt_right` slot content
- terminal width changes
- optional OpenCode sidebar width

`PromptRightContent` measures the original right slot width via `onSizeChange`. `StatuslineView` also reserves the host `auto` label and latest model variant, then computes its budget as:

```text
estimated prompt inner width
- estimated native left model row width
- measured native right-side prompt width
- row gaps and safety columns
```

If the remaining width is below the minimum threshold, statusline output is hidden. Otherwise, text is truncated by terminal column width and rendered as fixed-width segments. This avoids wrapping onto the next prompt line.

## Active Model Resolution

Active model resolution is centralized in `src/lib/opencode-client.ts`.

Inputs may come from:

| Source | Notes |
| --- | --- |
| command model | Used by server-style callers when provided |
| OpenCode config model | `config.model`, usually `<provider>/<model>` |
| recent TUI model state | `${XDG_STATE_HOME:-~/.local/state}/opencode/model.json` |
| session model | `session.model.providerID` / `session.model.modelID` |
| latest message model | fallback from recent messages |

Recent model state is useful after model switching in the TUI. The TUI-provided `api.state.path.state` is authoritative; environment/XDG resolution is only a fallback. The statusline polls only the local `model.json` signature every 2 seconds and queries providers only when selected fields require quota data.

Override the state directory with `OPENCODE_STATUSLINE_STATE_DIR`.

## Refresh Model

Statusline refreshes happen on:

| Trigger | Behavior |
| --- | --- |
| `/statusline` field selection change | queued reload at 150ms and 600ms |
| `session.updated` | queued reload at 150ms and 600ms for the current session |
| `message.updated` / `message.removed` | queued reload at 150ms and 600ms for token/context-related fields |
| `tui.session.select` | queued reload at 150ms and 600ms when the active session changes |
| `session.sidebar.toggle` command | recompute layout budget |
| recent model state file signature change | reload after local model switch detection |
| 60 second interval | full fallback refresh |

Streaming `message.part.updated` and `message.part.delta` events do not trigger a full statusline rebuild; the next `message.updated` or session event refreshes the final token/context data.

Provider quota collection has a credential-scoped 60 second fresh cache and 10 minute stale cache. Network deadlines cover both headers and body parsing. Statusline rendering adds a 2.5 second outer deadline; concurrent refreshes for the same account share one request. `/usage` forces fresh data and guards async results so closing or reopening the dialog cannot apply a stale response.

## Context Hygiene

The plugin avoids context pollution by:

- registering `/usage` and `/statusline` as TUI keymap slash commands
- showing usage data in TUI dialogs instead of chat messages
- keeping statusline data in prompt UI only
- not using server-side command injection for these interactive commands

The package still ships a server entry as an empty shim for compatibility with package-based plugin loading.

## Provider Layer

Provider collectors live in `src/lib/providers.ts`. Each collector:

1. resolves credentials
2. queries a provider endpoint
3. converts provider-specific data into `UsageReport`
4. returns an error report instead of throwing to UI callers

Detailed provider endpoints and response mappings are documented in [provider-query-methods.md](./provider-query-methods.md).

## Known Limits

- OpenCode does not expose every local TUI state value through the plugin API, so model switch detection relies partly on local recent model state.
- OpenAI OAuth tokens are read but not refreshed by this plugin.
- Provider quota fields only render windows that the provider exposes.
