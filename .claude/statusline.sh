#!/usr/bin/env bash

# 色定義
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
RESET="\033[0m"

# 使用率に応じて色付きパーセントを返す (90%↑: 赤, 70%↑: 黄, それ以外: 緑)
colorize_pct() {
    local pct=$1
    local color=$GREEN
    [ "$pct" -ge 70 ] && color=$YELLOW
    [ "$pct" -ge 90 ] && color=$RED
    echo -e "${color}${pct}%${RESET}"
}

# Read JSON input from stdin
input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Git branch
GIT_BRANCH=""
if git rev-parse &>/dev/null; then
    BRANCH=$(git branch --show-current)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" |  $BRANCH"
    else
        COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$COMMIT_HASH" ]; then
            GIT_BRANCH=" |  HEAD ($COMMIT_HASH)"
        fi
    fi
fi

# コンテキストウィンドウ使用率（コンパクション目安）
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
CTX_DISPLAY=$(colorize_pct "$used_pct")

# セッションコスト（JSON から直接取得）
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
SESSION_COST=$(printf "$%.2f" "$session_cost")

# レートリミット（Pro/Max のみ、null の場合は非表示）
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

RATE_DISPLAY=""
if [ -n "$rate_5h" ]; then
    r5=$(printf "%.0f" "$rate_5h")
    r5_fmt=$(colorize_pct "$r5")

    r7_fmt=""
    if [ -n "$rate_7d" ]; then
        r7=$(printf "%.0f" "$rate_7d")
        r7_fmt="/7d $(colorize_pct "$r7")"
    fi

    RATE_DISPLAY=" | 󱎫 lmt: 5h ${r5_fmt}${r7_fmt}"
fi

# ccusage から today コストと残り時間を取得
full_status_line=$(echo "$input" | bun x ccusage@latest statusline "$@")
money_info=$(echo "$full_status_line" | cut -d '|' -f 2)
today_info=$(echo "$money_info" | cut -d '/' -f 2 | xargs)
block_info_raw=$(echo "$money_info" | cut -d '/' -f 3 | xargs)
time_left=$(echo "$block_info_raw" | sed 's/.*(\(.*\))/\1/')

echo "󰚩 ${MODEL_DISPLAY} |  ${CURRENT_DIR##*/}${GIT_BRANCH} | 󰍛 ctx: ${CTX_DISPLAY}"
echo "󰃰 ${today_info}/${SESSION_COST} session${RATE_DISPLAY} | 󰔟 ${time_left}"
