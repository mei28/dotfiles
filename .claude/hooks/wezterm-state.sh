#!/usr/bin/env bash
# Set WezTerm user variables for Claude Code state and title
# States: idle, thinking, executing (empty to clear)

# フック実行時 controlling TTY 無いケース有り (Claude Code 2.x)。
# /dev/tty 不可なら親プロセス (Claude Code) の TTY 経由で OSC 送出。
resolve_target_tty() {
	if : > /dev/tty 2>/dev/null; then
		echo /dev/tty
		return
	fi
	local t
	t=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
	[ -n "$t" ] && [ "$t" != "?" ] && [ "$t" != "??" ] && [ -w "/dev/$t" ] && echo "/dev/$t"
}

TARGET_TTY=$(resolve_target_tty)

set_user_var() {
	[ -z "$TARGET_TTY" ] && return 0
	local value
	value=$(printf '%s' "$2" | base64)
	if [ -n "$TMUX" ]; then
		# tmux: DCS passthrough で OSC を外側のターミナルへ転送
		printf '\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\' "$1" "$value" > "$TARGET_TTY" 2>/dev/null || true
	else
		printf '\033]1337;SetUserVar=%s=%s\007' "$1" "$value" > "$TARGET_TTY" 2>/dev/null || true
	fi
}

# ペーン識別子: WezTerm直接 → WEZTERM_PANE, tmux内 → TMUX_PANE
pane_id="${WEZTERM_PANE:-${TMUX_PANE}}"
prompt_file="/tmp/claude-prompt-${pane_id}"

save_prompt() {
	[ -n "$pane_id" ] && printf '%s' "$1" > "$prompt_file"
}

load_prompt() {
	[ -n "$pane_id" ] && [ -f "$prompt_file" ] && cat "$prompt_file"
}

# Extract human-readable detail from tool_name + tool_input
extract_tool_detail() {
	local json="$1"
	local tool
	tool=$(printf '%s' "$json" | jq -r '.tool_name // empty' 2>/dev/null)
	local detail=""
	case "$tool" in
		Bash)
			detail=$(printf '%s' "$json" | jq -r '.tool_input.command // empty' 2>/dev/null | head -1 | cut -c1-40)
			;;
		Read|Edit|Write|Glob)
			local path
			path=$(printf '%s' "$json" | jq -r '.tool_input.file_path // .tool_input.pattern // empty' 2>/dev/null)
			detail=$(basename "$path" 2>/dev/null || echo "$path")
			;;
		Grep)
			detail=$(printf '%s' "$json" | jq -r '.tool_input.pattern // empty' 2>/dev/null | cut -c1-30)
			;;
		Agent)
			detail=$(printf '%s' "$json" | jq -r '.tool_input.description // empty' 2>/dev/null | cut -c1-30)
			;;
	esac
	printf '%s' "${detail:-$tool}"
}

state="${1:-}"
input=$(cat)

set_user_var claude_state "$state"

title=""
case "$state" in
	executing)
		title=$(extract_tool_detail "$input")
		;;
	thinking)
		event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)
		if [ "$event" = "UserPromptSubmit" ]; then
			prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null | head -1 | cut -c1-30)
			save_prompt "$prompt"
			title="$prompt"
		else
			# PostToolUse - show what result Claude is processing
			detail=$(extract_tool_detail "$input")
			if [ -n "$detail" ]; then
				title="${detail} を確認中"
			else
				title=$(load_prompt)
				title="${title:-thinking...}"
			fi
		fi
		;;
	idle)
		title=$(load_prompt)
		title="${title:-Claude Code}"
		;;
	"")
		[ -n "$pane_id" ] && rm -f "$prompt_file"
		;;
esac

set_user_var claude_title "$title"
