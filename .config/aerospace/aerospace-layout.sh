#!/usr/bin/env bash
# aerospace-layout: Arrange windows on the focused workspace into predefined layouts
# Usage: aerospace-layout.sh <layout>
#   grid       - Pair windows vertically, arrange pairs horizontally (2x2-like)
#   main-left  - First window on left half, rest stacked on right
#   main-right - Last window on right half, rest stacked on left

layout="${1:-}"

# Collect only tiling windows (exclude floating, hidden apps, etc.)
windows=()
while IFS='|' read -r id wlayout; do
    case "$wlayout" in
        h_tiles|v_tiles|accordion) windows+=("$id") ;;
    esac
done < <(aerospace list-windows --workspace focused --format '%{window-id}|%{window-layout}')
n=${#windows[@]}

if [ "$n" -lt 2 ]; then
    exit 0
fi

aerospace flatten-workspace-tree
# layout may return non-zero if already in the desired state; ignore
aerospace layout tiles horizontal || true

case "$layout" in
    grid)
        # Join every 2nd window with the one to its left → vertical pairs
        # 2: [W1/W2]  3: [W1/W2][W3]  4: [W1/W2][W3/W4]  5: [W1/W2][W3/W4][W5]
        for ((i = 1; i < n; i += 2)); do
            aerospace focus --window-id "${windows[$i]}"
            aerospace join-with left
        done
        ;;
    main-left)
        # BSP split: W1 fixed on left half, W2+ recursively halved on right
        # [W1|(W2/(W3|(W4/W5)))]

        # Join last two windows to create the deepest BSP nest
        aerospace focus --window-id "${windows[$((n - 1))]}"
        aerospace join-with left

        # Join remaining windows in reverse with their right neighbor
        # Normalization automatically alternates container orientations
        for ((i = n - 2; i >= 1; i--)); do
            aerospace focus --window-id "${windows[$i]}"
            aerospace join-with right
        done
        ;;
    main-right)
        # BSP split: W1 fixed on right half, W2+ recursively halved on left (mirror of main-left)
        # [(W2/(W3|(W4/W5)))|W1]

        # Move W1 to the rightmost position while tree is flat
        for ((i = 1; i < n; i++)); do
            aerospace focus --window-id "${windows[0]}"
            aerospace move right
        done

        # Build BSP structure on W2-W5 (same logic as main-left)
        aerospace focus --window-id "${windows[$((n - 1))]}"
        aerospace join-with left

        for ((i = n - 2; i >= 1; i--)); do
            aerospace focus --window-id "${windows[$i]}"
            aerospace join-with right
        done
        ;;
    *)
        echo "Usage: aerospace-layout.sh [grid|main-left|main-right]" >&2
        exit 1
        ;;
esac
