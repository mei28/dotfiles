#!/bin/bash
# Remove ghost windows (closed windows still present in AeroSpace layout)
aerospace list-windows --all --json \
  | jq -r '.[] | select(."window-title"=="") | ."window-id"' \
  | xargs -n1 aerospace close --window-id
