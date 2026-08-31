# opencode-statusline

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

OpenCode TUI plugin for provider usage dialogs and configurable prompt statusline fields.

It adds:

- `/usage` to inspect the active provider's quota, usage, and balance data in a TUI dialog.
- `/statusline` to choose extra fields shown after OpenCode's prompt model/provider label.
- Colored statusline segments, ordered exactly as selected.
- No chat-context pollution: usage and statusline data are rendered only in the TUI.

## Screenshots

Example statusline fields appended to the OpenCode prompt:

![OpenCode prompt statusline with repository, branch, git diff, context, cost, token, TTFT, and generation speed fields](doc/images/statusline-overview.jpg)

`/usage` provider quota dialog:

![OpenCode usage dialog showing provider, model, auth source, plan, and quota windows](doc/images/usage-dialog.jpg)

## Install

Clone and build the plugin:

```sh
git clone https://github.com/kalcohol/opencode-statusline.git
cd opencode-statusline
npm install
npm run build
```

Get the absolute path to the cloned package:

```sh
pwd
```

Add that package path to OpenCode's TUI config. The usual global config file is:

```text
${XDG_CONFIG_HOME:-~/.config}/opencode/tui.jsonc
```

Create the directory/file if needed:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
${EDITOR:-vi} "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/tui.jsonc"
```

Use the absolute path printed by `pwd`:

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": ["/absolute/path/to/opencode-statusline"]
}
```

If the file already has plugins, append this package path to the existing `plugin` array:

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [
    "/absolute/path/to/another-plugin",
    "/absolute/path/to/opencode-statusline"
  ]
}
```

Restart the OpenCode TUI after changing plugin config or rebuilding the package. Then run `/usage` or `/statusline` inside OpenCode to verify the plugin is loaded.

To update an existing clone:

```sh
cd /absolute/path/to/opencode-statusline
git pull
npm install
npm run build
```

Then restart the OpenCode TUI.

`opencode.json` is not required for the current plugin, but keeping the same package path there is harmless:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["/absolute/path/to/opencode-statusline"]
}
```

Common global config locations:

```text
${XDG_CONFIG_HOME:-~/.config}/opencode/tui.jsonc
${XDG_CONFIG_HOME:-~/.config}/opencode/opencode.jsonc
```

Project-local config is also supported:

```text
<project>/.opencode/tui.jsonc
<project>/.opencode/opencode.jsonc
```

OpenCode also walks upward from the current project directory for `tui.json(c)` and `opencode.json(c)`. If `OPENCODE_CONFIG_DIR` is set, use that directory instead of the global default.

## Commands

### `/usage`

Shows usage/quota details for the active model's provider. The dialog does not send a model request and does not write usage data into the conversation.

The command resolves the active provider/model from the current session, recent TUI model state, or `config.model`. It fetches provider data fresh when opened.

Reset timestamps are shown in local time using fixed-width `YYYY-MM-DD HH:mm:ss` fields.

### `/statusline`

Opens a field picker. Selecting a field toggles it. The order you select fields is the order used in the prompt statusline.

Available fields:

| Field | Description |
| --- | --- |
| Repository | worktree or directory basename |
| Branch | current git branch name |
| Git diff stats | tracked staged+unstaged git diff line counts as `+123,-45` |
| Context used | latest token-bearing assistant context estimate |
| Context remaining | model context limit minus current context estimate |
| Context length | current model context limit |
| Context used/total | compact used/limit display |
| TTFT/speed | approximate time to first text/reasoning output and output+reasoning token speed; excludes tool execution time |
| Subagent status | active subagent or child-session status; idle/completed children are omitted |
| Main agent status | current main session status, without an `agent` prefix; transient `queued`/`pending` is omitted |
| 5h quota | provider 5h quota used percent, when available |
| Weekly quota | provider weekly quota used percent, when available |
| Provider balance | prepaid balance or remaining limit reported by the provider as `bal $12.34` |
| Session input/output tokens | accumulated session and nested descendant-session input/output tokens as `<input> in / <output> out` |
| Session total tokens | accumulated session and nested descendant-session total tokens as `<total> used`; includes reasoning/cache tokens |
| Session cost | accumulated session and nested descendant-session cost as `cost $0.02`; shows `eq $0.02` when estimated from model pricing |

Unavailable provider/model data is omitted. For example, OpenRouter has balance and usage totals, but no 5h subscription quota window.

`Provider balance` reuses the balance rows shown by `/usage`. It prefers remaining/limit remaining rows, then balance/credits rows. It renders for providers with balance data such as DeepSeek, OpenRouter, and OpenAI/Codex credits, and is omitted for pure subscription quota data with no money amount.

Quota/balance fields reuse the provider usage cache. After a manual `/usage` refresh, the statusline prefers cached data even during brief `queued`/`pending` states or while the session is busy, instead of clearing the fields.

`Git diff stats` reads only the local worktree and runs one `git diff HEAD --numstat`, avoiding staged/unstaged double counting. Untracked and binary files are excluded.

For subscription or coding-plan providers, `Session cost` may be an equivalent per-token estimate rather than an actual amount charged. It prefers OpenCode's recorded message cost when present, then falls back to model catalog pricing.

The statusline uses one precompiled OpenTUI 0.4 path on every platform. It wraps `session_prompt`, places fields in the Prompt `right` content, and preserves existing `session_prompt_right` content. Fields are truncated by real terminal column width to prevent wrapping.

## Supported Providers

`/usage` and quota statusline fields currently support these provider IDs. Matching is case-insensitive.

| Provider / plan | Provider IDs | Credential hints | Data shown when available |
| --- | --- | --- | --- |
| Z.ai coding plan | `zai`, `zai-coding-plan` | `ZAI_API_KEY`, `ZAI_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota, time quota |
| Zhipu coding plan | `zhipu`, `zhipuai`, `zhipu-coding-plan`, `zhipuai-coding-plan` | `ZHIPU_API_KEY`, `ZHIPU_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota, time quota |
| Kimi Code | `kimi`, `kimi-code`, `kimi-for-coding` | `KIMI_API_KEY`, `KIMI_CODE_API_KEY` | usage windows, including 5h when present |
| MiniMax coding plan | `minimax`, `minimax-coding-plan` | `MINIMAX_CODING_PLAN_API_KEY`, `MINIMAX_API_KEY` | international 5h and weekly token quota |
| MiniMax CN coding plan | `minimax-cn`, `minimax-china-coding-plan`, `minimax-cn-coding-plan` | `MINIMAX_CHINA_CODING_PLAN_API_KEY` | China 5h and weekly token quota |
| Xiaomi MiMo Token Plan | `xiaomi-mimo`, `xiaomi`, `mimo`, `mimo-token-plan`, `xiaomi-token-plan*` | model calls use `XIAOMI_TOKEN_PLAN_API_KEY` / `MIMO_API_KEY`; usage requires `XIAOMI_MIMO_SESSION_COOKIE` | plan/compensation/monthly credits quota, credits remaining |
| DeepSeek | `deepseek` | `DEEPSEEK_API_KEY` | account balance and availability |
| OpenRouter | `openrouter` | `OPENROUTER_API_KEY` | key label, remaining limit, total limit, usage totals |
| OpenCode Go | `opencode-go`, `opencodego` | `OPENCODE_API_KEY` or the provider key saved by OpenCode | 5h, weekly, and monthly subscription quota |
| OpenAI / ChatGPT / Codex OAuth | `openai`, `codex`, `chatgpt` | OAuth entry in OpenCode `auth.json` | ChatGPT plan, 5h/weekly/monthly quota, code review quota, credits |

API-key providers resolve credentials in this order:

1. environment variables
2. OpenCode `provider.<id>.options.apiKey`
3. runtime provider key
4. OpenCode `auth.json`

OpenCode Go queries `GET https://opencode.ai/zen/go/v1/usage` with the regular Go API key as a Bearer token. The plugin normally reuses the `opencode-go` key from OpenCode config or `auth.json`; you can also set `OPENCODE_API_KEY` explicitly. A workspace ID and browser cookie are no longer required.

OpenAI/ChatGPT/Codex usage uses OAuth from `auth.json`. `opencode` / OpenCode Zen is recognized, but OpenCode Zen does not currently expose a public balance/quota API, so quota fields are omitted.

For Xiaomi MiMo Token Plan, the `tp-*` key is for OpenCode model calls. Xiaomi's current usage endpoint is behind SSO and rejects the `tp-*` key. To show Xiaomi data in `/usage` and statusline quota/balance fields, set `XIAOMI_MIMO_SESSION_COOKIE` from a logged-in browser session and do not commit the cookie.

With only a `tp-*` key and no cookie, Xiaomi models can still be identified. Statusline fields that do not use the provider usage API, such as context, session tokens, session cost, TTFT, and git diff, still work; Xiaomi quota fields are omitted or `/usage` reports the missing cookie.

Detailed endpoint notes are in [doc/provider-query-methods.en.md](doc/provider-query-methods.en.md).

## State Files

The statusline field selection is stored at:

```text
${XDG_DATA_HOME:-~/.local/share}/opencode/statusline-plugin.json
```

Override with:

```text
OPENCODE_STATUSLINE_CONFIG=/path/to/statusline-plugin.json
```

After a TUI model switch, the plugin reads OpenCode's recent model state from:

```text
${XDG_STATE_HOME:-~/.local/state}/opencode/model.json
```

Override the state directory with:

```text
OPENCODE_STATUSLINE_STATE_DIR=/path/to/opencode-state
```

## Development

Useful commands:

```sh
npm run typecheck
npm test
npm run build
```

If the local `/tmp` mount rejects Node/Vitest writes, point `TMPDIR` at an ignored project-local directory:

```sh
mkdir -p .tmp
TMPDIR=$PWD/.tmp npm test
```

OpenCode resolves the precompiled TUI entry from `dist/tui.js`, so run `npm run build` after source changes before testing in the TUI.

Source layout:

```text
src/
  index.ts                 package server entry
  plugin.ts                empty server shim
  tui.tsx                  TUI slots, dialogs, slash commands, statusline rendering
  lib/
    auth.ts                env/config/auth.json credential lookup
    opencode-client.ts     active model resolution helpers
    providers.ts           provider usage collectors
    statusline.ts          statusline field renderer
    statusline-config.ts   persisted field selection
    tui-usage.ts           /usage dialog text builder
    usage-format.ts        usage report formatting
    format.ts              shared formatting helpers
```

Architecture details are in [doc/plugin-architecture.en.md](doc/plugin-architecture.en.md).
