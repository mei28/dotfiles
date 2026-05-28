#!/usr/bin/env bash
# Copy the last command (prompt + input + output) to clipboard.
# Mirrors WezTerm's ctrl+q z behavior.
set -euo pipefail

output=$(cmux capture-pane --scrollback --lines 500 2>/dev/null)

result=$(echo "$output" | awk '
/\$ / { prompts[++n] = NR; lines[n] = $0 }
{ all[NR] = $0 }
END {
  if (n < 2) exit 1
  start = prompts[n-1]
  end = prompts[n] - 1
  for (i = start; i <= end; i++) print all[i]
}
')

if [[ -z "$result" ]]; then
  cmux notify --title "copy-last-cmd" --body "No previous command found" 2>/dev/null
  exit 1
fi

echo "$result" | pbcopy
cmux notify --title "Copied" --body "Last command + output copied to clipboard" 2>/dev/null
printf '\033[1A\033[2K\r'
