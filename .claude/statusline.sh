#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path')

# Get git branch information
GIT_BRANCH=""
if git rev-parse &>/dev/null; then
    BRANCH=$(git branch --show-current)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" |  $BRANCH"
    else
        COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$COMMIT_HASH" ]; then
            GIT_BRANCH=" |  HEAD ($COMMIT_HASH)"
        fi
    fi
fi

# Get token summary
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    TOKEN_COUNT="_ tkns. (_%)"
else
    # Get last assistant message with usage data using jq
    total_tokens=$(tail -n 100 "$TRANSCRIPT_PATH" 2>/dev/null | \
            jq -s 'map(select(.type == "assistant" and .message.usage)) |
    last |
    .message.usage |
    (.input_tokens // 0) +
    (.output_tokens // 0) +
    (.cache_creation_input_tokens // 0) +
    (.cache_read_input_tokens // 0)' 2>/dev/null)

    # Default to 0 if no valid result
    total_tokens=${total_tokens:-0}

    # max token count: 200k
    # compaction threshold: 80% (160k)
    COMPACTION_THRESHOLD=160000
    # Calculate percentage
    percentage=$((total_tokens * 100 / COMPACTION_THRESHOLD))

    # Format token display
    if [ "$total_tokens" -ge 1000 ]; then
        thousands=$(echo "scale=1; $total_tokens/1000" | bc)
        token_display=$(printf "%.1fK" "$thousands")
    else
        token_display="$total_tokens"
    fi

    # Color coding for percentage
    if [ "$percentage" -ge 90 ]; then
        color="\033[31m"  # Red
    elif [ "$percentage" -ge 70 ]; then
        color="\033[33m"  # Yellow
    else
        color="\033[32m"  # Green
    fi

    # Format: "123 tkns. (10%)"
    TOKEN_COUNT=$(echo -e "${token_display} tkns. (${color}${percentage}%\033[0m)")
fi

full_status_line=$(echo "$input" | bun x ccusage@latest statusline "$@")

# ccusage出力の2番目のフィールド（金額情報）を抽出
# 例: " 💰 $0.23 session / $1.23 today / $0.45 block (2h 45m left) "
money_info=$(echo "$full_status_line" | cut -d '|' -f 2)

# `/` で区切って2番目の要素 (" $1.23 today ") を抽出し、xargsで前後の空白を削除
today_info=$(echo "$money_info" | cut -d '/' -f 2 | xargs)

# `/` で区切って3番目の要素 (" $0.45 block (2h 45m left) ") を抽出し、xargsで空白削除
block_info_raw=$(echo "$money_info" | cut -d '/' -f 3 | xargs)
# 括弧内の残り時間 ("2h 45m left") を抽出
time_left=$(echo "$block_info_raw" | sed 's/.*(\(.*\))/\1/')

echo "󰚩 ${MODEL_DISPLAY} |  ${CURRENT_DIR##*/}${GIT_BRANCH} |  ${TOKEN_COUNT} | 󰃰 ${today_info} | 󰔟 ${time_left}"

