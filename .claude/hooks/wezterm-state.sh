#!/usr/bin/env bash
# Set WezTerm user variables for Claude Code state and title
# States: idle, thinking, executing (empty to clear)

set_user_var() {
	printf '\033]1337;SetUserVar=%s=%s\007' "$1" "$(printf '%s' "$2" | base64)" > /dev/tty 2>/dev/null || true
}

prompt_file="/tmp/claude-prompt-${WEZTERM_PANE}"

save_prompt() {
	[ -n "$WEZTERM_PANE" ] && printf '%s' "$1" > "$prompt_file"
}

load_prompt() {
	[ -n "$WEZTERM_PANE" ] && [ -f "$prompt_file" ] && cat "$prompt_file"
}

# Extract human-readable detail from tool_name + tool_input
extract_tool_detail() {
	local json="$1"
	local tool=$(printf '%s' "$json" | jq -r '.tool_name // empty' 2>/dev/null)
	local detail=""
	case "$tool" in
		Bash)
			detail=$(printf '%s' "$json" | jq -r '.tool_input.command // empty' 2>/dev/null | head -1 | cut -c1-40)
			;;
		Read|Edit|Write|Glob)
			local path=$(printf '%s' "$json" | jq -r '.tool_input.file_path // .tool_input.pattern // empty' 2>/dev/null)
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
		[ -n "$WEZTERM_PANE" ] && rm -f "$prompt_file"
		;;
esac

set_user_var claude_title "$title"
