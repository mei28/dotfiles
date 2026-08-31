# Provider Quota Query Methods

[中文](provider-query-methods.md) | [English](provider-query-methods.en.md) | [日本語](provider-query-methods.ja.md)

この文書は `opencode-statusline` が実装している provider usage/quota query methods を説明します。実装入口は `src/lib/providers.ts` で、provider-specific response を `UsageReport` に normalize し、`/usage` dialog と quota/balance statusline fields で再利用します。

Statusline の `session_cost` field は、この provider quota collector を使いません。まず OpenCode assistant message に記録された `cost` を読み、存在しない場合だけ current model catalog pricing と token counts から equivalent cost を推定します。

## Credential Resolution

API-key providers は次の順序で credentials を解決します。

1. provider-specific environment variables
2. OpenCode config `provider.<id>.options.apiKey`
3. runtime provider `key`
4. OpenCode `auth.json` の API-key entries

`provider.<id>.options.apiKey` は `{env:VAR_NAME}` template をサポートします。OAuth providers は `auth.json` の OAuth token だけを読みます。

default `auth.json` locations：

| Platform | Path |
| --- | --- |
| All platforms | `${XDG_DATA_HOME:-~/.local/share}/opencode/auth.json` |

`OPENCODE_AUTH_JSON` で上書きできます。

## Provider Overview

| Provider / plan | Provider IDs | Credential hints | 表示データ |
| --- | --- | --- | --- |
| Z.ai coding plan | `zai`, `zai-coding-plan` | `ZAI_API_KEY`, `ZAI_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota、time quota |
| Zhipu coding plan | `zhipu`, `zhipuai`, `zhipu-coding-plan`, `zhipuai-coding-plan` | `ZHIPU_API_KEY`, `ZHIPU_CODING_PLAN_API_KEY` | 5h/daily/weekly token quota、time quota |
| Kimi Code | `kimi`, `kimi-code`, `kimi-for-coding` | `KIMI_API_KEY`, `KIMI_CODE_API_KEY` | usage window、存在する場合は 5h window |
| MiniMax coding plan | `minimax`, `minimax-coding-plan` | `MINIMAX_CODING_PLAN_API_KEY`, `MINIMAX_API_KEY` | 5h quota、weekly quota |
| MiniMax CN coding plan | `minimax-cn`, `minimax-china-coding-plan`, `minimax-cn-coding-plan` | `MINIMAX_CHINA_CODING_PLAN_API_KEY` | 5h quota、weekly quota |
| Xiaomi MiMo Token Plan | `xiaomi-mimo`, `xiaomi`, `mimo`, `mimo-token-plan`, `xiaomi-token-plan*` | usage は `XIAOMI_MIMO_SESSION_COOKIE`、model calls は `XIAOMI_TOKEN_PLAN_API_KEY` / `MIMO_API_KEY` | plan/compensation/monthly credits quota、credits remaining |
| DeepSeek | `deepseek` | `DEEPSEEK_API_KEY` | account balance、availability |
| OpenRouter | `openrouter` | `OPENROUTER_API_KEY` | key label、remaining limit、usage totals |
| OpenCode Go | `opencode-go`, `opencodego` | `OPENCODE_API_KEY` または OpenCode が保存した provider key | 5h/weekly/monthly subscription quota |
| OpenAI / ChatGPT / Codex OAuth | `openai`, `codex`, `chatgpt` | OpenCode `auth.json` OAuth entry | ChatGPT plan、5h/weekly/monthly quota、code review quota、credits |
| OpenCode Zen | `opencode` | N/A | recognized, but no public quota API |

Provider IDs は大文字小文字を区別せずに match します。

## Z.ai / Zhipu Coding Plan

Z.ai と Zhipu は同じ response shape を使います。plugin は現在 quota endpoint だけを呼びます。

| Provider kind | Endpoint |
| --- | --- |
| Z.ai | `GET https://api.z.ai/api/monitor/usage/quota/limit` |
| Zhipu / BigModel | `GET https://bigmodel.cn/api/monitor/usage/quota/limit` |

Headers：

```text
Authorization: <token>
Content-Type: application/json
User-Agent: OpenCode-Statusline/0.1
```

token は `Bearer ` prefix なしでそのまま送ります。

Typical response shape：

```json
{
  "data": {
    "limits": [
      {
        "type": "TOKENS_LIMIT",
        "unit": 3,
        "percentage": 45.2,
        "nextResetTime": 1760000000000
      },
      {
        "type": "TIME_LIMIT",
        "percentage": 30.1,
        "currentValue": 1800,
        "usage": 6000
      }
    ]
  }
}
```

Mapping：

| Response | Usage window |
| --- | --- |
| `type === "TOKENS_LIMIT"`, `unit === 6` | weekly quota |
| `type === "TOKENS_LIMIT"`, `unit === 4` | daily quota |
| `type === "TOKENS_LIMIT"`, `unit === 3` または first token window | 5h quota |
| `type === "TIME_LIMIT"` | monthly time quota |

plugin は `percentage` を used percent として使い、存在する場合は `nextResetTime` を reset time として使います。

## Kimi Code

Endpoint：

```text
GET https://api.kimi.com/coding/v1/usages
```

Headers：

```text
Authorization: Bearer <token>
User-Agent: OpenCode-Statusline/0.1
```

Supported response variants：

```json
{
  "data": {
    "usage": {
      "limit": 100,
      "used": 45,
      "remaining": 55,
      "name": "Kimi Code",
      "reset_at": "2026-06-01T00:00:00Z"
    },
    "limits": [
      {
        "name": "rolling",
        "detail": {
          "limit": 100,
          "used": 45,
          "remaining": 55,
          "reset_at": "2026-06-01T00:00:00Z"
        },
        "window": {
          "duration": 5,
          "timeUnit": "HOUR"
        }
      }
    ]
  }
}
```

parser は top-level `usage` と `data.usage` の両方を受け付けます。`used` から used count を取得し、`remaining` しかない場合は `limit - remaining` で計算します。`limits[]` row の `window.duration === 5` かつ `window.timeUnit` が `HOUR` を含む場合、5h quota window に map します。

## MiniMax Coding Plans

Endpoints：

```text
International: GET https://api.minimax.io/v1/api/openplatform/coding_plan/remains
China:         GET https://api.minimaxi.com/v1/token_plan/remains
```

Headers：

```text
Authorization: Bearer <token>
User-Agent: OpenCode-Statusline/0.1
```

Response shape：

```json
{
  "model_remains": [
    {
      "model_name": "MiniMax-M*",
      "current_interval_total_count": 100,
      "current_interval_usage_count": 30,
      "remains_time": 18000,
      "current_weekly_total_count": 500,
      "current_weekly_usage_count": 150,
      "weekly_remains_time": 432000
    }
  ],
  "base_resp": {
    "status_code": 0,
    "status_msg": "success"
  }
}
```

generic `minimax` provider は international endpoint を使い、explicit CN aliases だけが China endpoint を使います。実装は `MiniMax-M*` wildcard row を優先し、次に current model id と一致する row、最後に first row を選び、`*_usage_count` を used count として扱います。

| Response fields | Usage window |
| --- | --- |
| `current_interval_usage_count` / `current_interval_total_count`, `remains_time` | 5h quota |
| `current_weekly_usage_count` / `current_weekly_total_count`, `weekly_remains_time` | weekly quota |

## Xiaomi MiMo Token Plan

Xiaomi 公式 docs では Token Plan API key は `tp-xxxxx` format で、OpenAI-compatible base URL は `https://token-plan-cn.xiaomimimo.com/v1`、`https://token-plan-sgp.xiaomimimo.com/v1`、`https://token-plan-ams.xiaomimimo.com/v1` などです。これらの key は model calls 用です。現在の usage endpoint は console/SSO endpoint で、`tp-*` key は拒否されるため、plugin は usage lookup に logged-in browser cookie を必要とします。

Endpoint：

```text
GET https://platform.xiaomimimo.com/api/v1/tokenPlan/usage
```

Headers：

```text
Cookie: <XIAOMI_MIMO_SESSION_COOKIE>
User-Agent: OpenCode-Statusline/0.1
```

Response shape：

```json
{
  "code": 0,
  "data": {
    "usage": {
      "items": [
        { "name": "plan_total_token", "used": 12000000, "limit": 60000000, "percent": 20 },
        { "name": "compensation_total_token", "used": 500000, "limit": 1000000, "percent": 50 }
      ]
    },
    "monthUsage": {
      "items": [
        { "name": "month_total_token", "used": 12500000, "limit": 61000000, "percent": 20.49 }
      ]
    }
  }
}
```

Mapping：

| Response item | Usage output |
| --- | --- |
| `usage.items[].name === "plan_total_token"` | Plan quota と `Credits remaining` balance |
| `usage.items[].name === "compensation_total_token"` | Compensation quota |
| `monthUsage.items[].name === "month_total_token"` | Monthly quota |

usage dialog は credit windows に `credits` suffix を付けて表示します。`Provider balance` statusline field は `Credits remaining` を使い、たとえば `bal 48M credits` のように compact に描画します。

## DeepSeek

Endpoint：

```text
GET https://api.deepseek.com/user/balance
```

Headers：

```text
Authorization: Bearer <token>
User-Agent: OpenCode-Statusline/0.1
```

Response shape：

```json
{
  "is_available": true,
  "balance_infos": [
    {
      "currency": "CNY",
      "total_balance": "10.50",
      "granted_balance": "5.00",
      "topped_up_balance": "5.50"
    }
  ]
}
```

DeepSeek は rolling quota windows ではなく account balances を公開します。plugin は各 currency balance を format し、存在する場合は granted/topped-up split rows も含めます。

## OpenRouter

Endpoint：

```text
GET https://openrouter.ai/api/v1/key
```

Headers：

```text
Authorization: Bearer <token>
User-Agent: OpenCode-Statusline/0.1
```

Response shape：

```json
{
  "data": {
    "label": "sk-or-v1-abc...123",
    "limit": 1000,
    "limit_remaining": 750.5,
    "limit_reset": "daily",
    "usage": 12345.67,
    "usage_daily": 42.1,
    "usage_weekly": 230.5,
    "usage_monthly": 1200,
    "byok_usage": 0,
    "is_free_tier": false
  }
}
```

plugin は key label、limit/remaining limit、reset label、usage totals、BYOK usage、free-tier state を表示します。OpenRouter は coding plans と同じ意味の 5h/weekly subscription windows を公開していません。

## OpenCode Go

OpenCode Go は API-key authentication 対応の JSON usage endpoint を公開しています。plugin は冒頭の標準 API key resolution order を使います。`OPENCODE_API_KEY` を明示設定するか、OpenCode config、runtime provider、または `auth.json` に保存された `opencode-go` key をそのまま再利用できます。

```text
GET https://opencode.ai/zen/go/v1/usage
Authorization: Bearer <token>
User-Agent: OpenCode-Statusline/0.1
```

Response shape：

```json
{
  "usage": {
    "rolling": {
      "status": "ok",
      "percent": 12.5,
      "resetsAt": "2026-08-19T01:00:00.000Z"
    },
    "weekly": {
      "status": "ok",
      "percent": 30,
      "resetsAt": "2026-08-24T00:00:00.000Z"
    },
    "monthly": {
      "status": "ok",
      "percent": 45,
      "resetsAt": "2026-09-18T00:00:00.000Z"
    }
  }
}
```

`usage.rolling`、`usage.weekly`、`usage.monthly` はそれぞれ 5h、weekly、monthly quota window に map します。`percent` は used percentage、`resetsAt` は absolute ISO 8601 reset time です。`status` は `ok` または `rate-limited` になります。この query は workspace ID と browser cookie を必要としません。

## OpenAI / ChatGPT / Codex OAuth

Endpoint：

```text
GET https://chatgpt.com/backend-api/wham/usage
```

Credentials：

| Source | Keys |
| --- | --- |
| OpenCode `auth.json` OAuth entry | `openai`, `codex`, `chatgpt`, `opencode` |

Headers：

```text
Authorization: Bearer <oauth-access-token>
ChatGPT-Account-Id: <accountId>
User-Agent: OpenCode-Statusline/0.1
```

plugin は auth.json から `.access`、`.expires`、`.accountId` を読みます。`accountId` がない場合は JWT claim `https://api.openai.com/auth.chatgpt_account_id` の decode を試みます。

Response shape：

```json
{
  "plan_type": "chatgptplusplan",
  "rate_limit": {
    "limit_reached": false,
    "primary_window": {
      "used_percent": 45,
      "limit_window_seconds": 18000,
      "reset_after_seconds": 7200,
      "reset_at": 1700000000
    },
    "secondary_window": {
      "used_percent": 20,
      "limit_window_seconds": 604800,
      "reset_after_seconds": 302400,
      "reset_at": 1700400000
    }
  },
  "code_review_rate_limit": {
    "primary_window": {
      "used_percent": 10,
      "reset_after_seconds": 43200
    }
  },
  "credits": {
    "has_credits": true,
    "unlimited": false,
    "balance": "50.00"
  }
}
```

Mapping：

| Response | Usage window / item |
| --- | --- |
| `rate_limit.primary_window` / `secondary_window` | `limit_window_seconds` で分類：18000 = 5h、604800 = weekly、2628000 = monthly |
| `code_review_rate_limit.primary_window` | code review quota |
| `credits` | credits balance / unlimited state |

expired OAuth access tokens は unavailable として報告されます。この plugin は OAuth token を refresh しません。

## OpenCode Zen

Provider id `opencode` は認識されますが、OpenCode Zen は現在 public balance/quota API を持ちません。collector は意図的に説明付き error を返し、`/usage` が quota fields が省略される理由を表示できるようにします。

## Normalization Rules

すべての collector は provider-specific data を次に normalize します。

| Field | Meaning |
| --- | --- |
| `windows[]` | 5h、daily、weekly、monthly、code review などの quota windows |
| `balances[]` | `/usage` と `Provider balance` statusline field が使う account balance-like rows |
| `items[]` | key label、model row、free tier、plan details などの miscellaneous labels |
| `usedPercent` / `remainingPercent` | `0..100` に clamp |
| `resetAtMs` / `resetAfterMs` | UI formatting で reset time を表示するために使用 |

absolute reset timestamps は `/usage` で local time の固定幅 `YYYY-MM-DD HH:mm:ss` fields として表示します。relative reset durations は compact duration text のままです。

Quota collection は provider/model kind ごとに 60 秒 cache され、statusline fallback 用に stale result を 10 分保持します。`/usage` は fresh read を強制して cache を更新します。statusline quota/balance fields は cached rows を先に使い、並行する in-flight refresh を共有し、statusline 側で 2.5 秒 timeout も適用します。
