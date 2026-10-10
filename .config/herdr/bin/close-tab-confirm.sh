#!/usr/bin/env bash
# Ask before closing the active tab, so a stray prefix+shift+x cannot make a
# tab (and, when it is the last one, the whole workspace) vanish without
# warning.
#
# Wired up as a popup custom command in config.toml. herdr runs popup commands
# through /bin/sh -c with HERDR_ACTIVE_TAB_ID set to the tab that was focused
# when the key was pressed.

set -eu

: "${HERDR_ACTIVE_TAB_ID:?HERDR_ACTIVE_TAB_ID is not set}"

printf 'Close this tab? [y/N] '
if ! read -n 1 ans; then
    # Input closed without an answer; treat as cancel.
    exit 0
fi
printf '\n'

case "$ans" in
    y | Y) herdr tab close "$HERDR_ACTIVE_TAB_ID" ;;
    *) exit 0 ;;
esac
