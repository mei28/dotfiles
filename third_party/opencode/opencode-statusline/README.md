# opencode-statusline

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

OpenCode TUI 插件，用于在 TUI 内查看 provider usage/quota，并按需扩展 prompt statusline。

它提供：

- `/usage`：在 TUI dialog 中查看当前活跃模型所属 provider 的 quota、usage、balance 等信息。
- `/statusline`：选择要追加到 OpenCode prompt 模型/provider 后面的状态字段。
- 彩色 statusline 字段，并严格按选择顺序显示。
- 不污染聊天上下文：usage 和 statusline 信息只渲染在 TUI 中，不写入对话历史。

## 截图

OpenCode prompt 中追加的示例 statusline 字段：

![OpenCode prompt statusline 示例，包含仓库、分支、git diff、上下文、成本、token、TTFT 和生成速度字段](doc/images/statusline-overview.jpg)

`/usage` provider quota dialog：

![OpenCode usage dialog showing provider, model, auth source, plan, and quota windows](doc/images/usage-dialog.jpg)

## 安装

克隆并构建插件：

```sh
git clone https://github.com/kalcohol/opencode-statusline.git
cd opencode-statusline
npm install
npm run build
```

查看插件目录的绝对路径：

```sh
pwd
```

把这个绝对路径加入 OpenCode 的 TUI 配置。常见的全局配置文件是：

```text
${XDG_CONFIG_HOME:-~/.config}/opencode/tui.jsonc
```

如果目录或文件还不存在，可以先创建并打开：

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
${EDITOR:-vi} "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/tui.jsonc"
```

使用 `pwd` 输出的绝对路径：

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": ["/absolute/path/to/opencode-statusline"]
}
```

如果已经有其他插件，把本插件路径追加到已有的 `plugin` 数组：

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [
    "/absolute/path/to/another-plugin",
    "/absolute/path/to/opencode-statusline"
  ]
}
```

修改插件配置或重新构建后，重启 OpenCode TUI。进入 OpenCode 后运行 `/usage` 或 `/statusline`，能打开对应界面就说明插件已加载。

更新已有 clone：

```sh
cd /absolute/path/to/opencode-statusline
git pull
npm install
npm run build
```

然后重启 OpenCode TUI。

当前插件不要求配置 `opencode.json`，但在其中保留同一个插件路径也没有问题：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["/absolute/path/to/opencode-statusline"]
}
```

常见全局配置位置：

```text
${XDG_CONFIG_HOME:-~/.config}/opencode/tui.jsonc
${XDG_CONFIG_HOME:-~/.config}/opencode/opencode.jsonc
```

也支持项目内配置：

```text
<project>/.opencode/tui.jsonc
<project>/.opencode/opencode.jsonc
```

OpenCode 会从当前项目目录向上查找 `tui.json(c)` 和 `opencode.json(c)`。如果设置了 `OPENCODE_CONFIG_DIR`，则使用该目录代替全局默认目录。

## 命令

### `/usage`

显示当前活跃模型所属 provider 的 usage/quota 信息。这个 dialog 不会发起模型请求，也不会把 usage 信息写入对话。

命令会从当前 session、近期 TUI 模型状态或 `config.model` 解析活跃 provider/model。每次打开 `/usage` 都会重新请求 provider 数据。

重置时间按本地时间显示，并使用固定宽度的 `YYYY-MM-DD HH:mm:ss` 格式。

### `/statusline`

打开字段选择器。选择字段会切换启用状态；字段选择顺序就是 prompt statusline 中的显示顺序。

可用字段：

| 字段 | 说明 |
| --- | --- |
| Repository | worktree 或目录 basename |
| Branch | 当前 git 分支名 |
| Git diff stats | tracked 文件的 staged+unstaged 增删行数，格式为 `+123,-45` |
| Context used | 最新带有效 token 的 assistant 消息上下文估算 |
| Context remaining | 模型上下文上限减去当前上下文估算 |
| Context length | 当前模型上下文上限 |
| Context used/total | 紧凑的已用/总上下文显示 |
| TTFT/speed | 到首个 text/reasoning 输出的近似延迟，以及 output+reasoning token 生成速度；tool 执行时间不计入 |
| Subagent status | 活跃 subagent 或 child-session 状态；idle/completed 的 child 会被省略 |
| Main agent status | 当前主 session 状态，不带 `agent` 前缀；瞬时 `queued`/`pending` 会省略 |
| 5h quota | provider 5h quota 使用百分比，有数据时显示 |
| Weekly quota | provider weekly quota 使用百分比，有数据时显示 |
| Provider balance | provider 返回的预付费余额或 remaining limit，格式为 `bal $12.34` |
| Session input/output tokens | 当前 session 和嵌套 descendant-session 累计输入/输出 token，格式为 `<input> in / <output> out` |
| Session total tokens | 当前 session 和嵌套 descendant-session 累计总 token，格式为 `<total> used`；reasoning/cache token 会计入 |
| Session cost | 当前 session 和嵌套 descendant-session 累计成本，格式为 `cost $0.02`；按模型价格估算时显示为 `eq $0.02` |

没有的数据会自动省略。例如 OpenRouter 有 balance 和 usage totals，但没有 coding plan 意义上的 5h subscription quota window，因此不会显示 `5h quota`。

`Provider balance` 复用 `/usage` dialog 的余额数据，优先显示 remaining/limit remaining，其次显示 balance/credits。DeepSeek、OpenRouter、OpenAI/Codex credits 等 provider 有余额数据时会显示；纯订阅 quota 没有钱数时会省略。

Quota/balance 字段会复用 provider usage 缓存；`/usage` 手动刷新后，statusline 即使遇到短暂 `queued`/`pending` 或正在 busy，也会优先显示已有缓存，而不是把字段清空。

`Git diff stats` 只读取本地 git 工作树，使用一次 `git diff HEAD --numstat` 统计 tracked 文件，避免 staged/unstaged 重复计数；未跟踪文件和二进制文件不会计入。

对于订阅制或 coding plan provider，`Session cost` 可能只是按 token 单价折算的等价估算，不一定代表真实扣费。它优先使用 OpenCode 记录在 message 上的 cost；没有记录时才回退到模型 catalog pricing。

Statusline 在所有平台使用同一套预编译 OpenTUI 0.4 路径：包装 `session_prompt`，把字段放入 Prompt 的 `right` 内容，并保留已有 `session_prompt_right` 内容。字段会按真实终端列宽动态截断，避免换行挤坏 prompt 布局。

## 支持的 Providers

`/usage` 和 quota statusline 字段当前支持以下 provider ID。匹配不区分大小写。

| Provider / plan | Provider IDs | 凭据提示 | 有数据时显示 |
| --- | --- | --- | --- |
| Z.ai coding plan | `zai`, `zai-coding-plan` | `ZAI_API_KEY`, `ZAI_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota，time quota |
| Zhipu coding plan | `zhipu`, `zhipuai`, `zhipu-coding-plan`, `zhipuai-coding-plan` | `ZHIPU_API_KEY`, `ZHIPU_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota，time quota |
| Kimi Code | `kimi`, `kimi-code`, `kimi-for-coding` | `KIMI_API_KEY`, `KIMI_CODE_API_KEY` | usage windows，包括存在时的 5h window |
| MiniMax coding plan | `minimax`, `minimax-coding-plan` | `MINIMAX_CODING_PLAN_API_KEY`, `MINIMAX_API_KEY` | 国际站 5h 和 weekly token quota |
| MiniMax CN coding plan | `minimax-cn`, `minimax-china-coding-plan`, `minimax-cn-coding-plan` | `MINIMAX_CHINA_CODING_PLAN_API_KEY` | 中国区 5h 和 weekly token quota |
| Xiaomi MiMo Token Plan | `xiaomi-mimo`, `xiaomi`, `mimo`, `mimo-token-plan`, `xiaomi-token-plan*` | 模型调用用 `XIAOMI_TOKEN_PLAN_API_KEY` / `MIMO_API_KEY`；usage 需要 `XIAOMI_MIMO_SESSION_COOKIE` | plan/compensation/monthly credits quota，credits remaining |
| DeepSeek | `deepseek` | `DEEPSEEK_API_KEY` | account balance 和 availability |
| OpenRouter | `openrouter` | `OPENROUTER_API_KEY` | key label、remaining limit、total limit、usage totals |
| OpenCode Go | `opencode-go`, `opencodego` | `OPENCODE_API_KEY` 或 OpenCode 已保存的 provider key | 5h、weekly、monthly subscription quota |
| OpenAI / ChatGPT / Codex OAuth | `openai`, `codex`, `chatgpt` | OpenCode `auth.json` OAuth entry | ChatGPT plan、5h/weekly/monthly quota、code review quota、credits |

API key 类 provider 按以下顺序解析凭据：

1. 环境变量
2. OpenCode `provider.<id>.options.apiKey`
3. runtime provider key
4. OpenCode `auth.json`

OpenCode Go 通过 `GET https://opencode.ai/zen/go/v1/usage` 查询额度，并使用常规 Go API key 进行 Bearer 认证。通常可直接复用 OpenCode 配置或 `auth.json` 中的 `opencode-go` key，也可显式设置 `OPENCODE_API_KEY`；不再需要 workspace ID 或浏览器 cookie。

OpenAI/ChatGPT/Codex usage 使用 `auth.json` 中的 OAuth。`opencode` / OpenCode Zen 会被识别，但 OpenCode Zen 目前没有公开的 balance/quota API，因此 quota 字段会省略。

Xiaomi MiMo Token Plan 的 `tp-*` key 用于 OpenCode 模型调用；小米当前的 usage endpoint 在 SSO 后台下，拒绝 `tp-*` key。要让 `/usage` 和 statusline quota/balance 字段显示小米额度，需要从已登录的浏览器会话设置 `XIAOMI_MIMO_SESSION_COOKIE`，不要把 cookie 写入仓库。

如果只有 `tp-*` key，没有 cookie，小米模型仍可被识别；上下文、session tokens、session cost、TTFT、git diff 等不依赖 provider usage API 的 statusline 字段仍可正常显示，但小米额度相关字段会省略或在 `/usage` 中提示 cookie 缺失。

详细 endpoint 说明见 [doc/provider-query-methods.md](doc/provider-query-methods.md)。

## 状态文件

Statusline 字段选择保存到：

```text
${XDG_DATA_HOME:-~/.local/share}/opencode/statusline-plugin.json
```

可用环境变量覆盖：

```text
OPENCODE_STATUSLINE_CONFIG=/path/to/statusline-plugin.json
```

TUI 内切换模型后，插件会从 OpenCode 最近模型状态读取：

```text
${XDG_STATE_HOME:-~/.local/state}/opencode/model.json
```

可用环境变量覆盖 state 目录：

```text
OPENCODE_STATUSLINE_STATE_DIR=/path/to/opencode-state
```

## 开发

常用命令：

```sh
npm run typecheck
npm test
npm run build
```

如果本地 `/tmp` 挂载点拒绝 Node/Vitest 写入，可以把 `TMPDIR` 指向项目内被忽略的临时目录：

```sh
mkdir -p .tmp
TMPDIR=$PWD/.tmp npm test
```

OpenCode 从预编译的 `dist/tui.js` 解析 TUI entry，因此改源码后要先运行 `npm run build` 再在 TUI 中测试。

源码结构：

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

架构细节见 [doc/plugin-architecture.md](doc/plugin-architecture.md)。
