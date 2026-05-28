#!/bin/bash
set -eu

CONFIG="$HOME/.config/ghostty/config"
LEVELS=(0.3 0.8 1.0)

current=$(grep -E '^background-opacity' "$CONFIG" | awk '{print $3}' || echo "1.0")

# find next level
next="${LEVELS[0]}"
for i in "${!LEVELS[@]}"; do
  if [[ "${LEVELS[$i]}" == "$current" ]]; then
    next_i=$(( (i + 1) % ${#LEVELS[@]} ))
    next="${LEVELS[$next_i]}"
    break
  fi
done

if grep -q '^background-opacity' "$CONFIG"; then
  sed -i '' "s/^background-opacity = .*/background-opacity = $next/" "$CONFIG"
else
  echo "background-opacity = $next" >> "$CONFIG"
fi

cmux reload-config > /dev/null 2>&1
# clear command trace from terminal
printf '\033[1A\033[2K\r'
