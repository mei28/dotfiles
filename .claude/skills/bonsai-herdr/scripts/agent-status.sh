#!/usr/bin/env bash
# Report herdr agent status for the agents a bonsai-herdr run owns.
#
# Usage:
#   agent-status.sh [--registered|--wait] [--timeout SECONDS] <agent-name>...
#
# Output: one `name<TAB>status<TAB>pane_id` line per requested name, in the order given.
#         A name herdr does not know is reported as `missing`.
#
# Modes:
#   (default)     print one snapshot and exit
#   --registered  poll until every name appears (herdr needs a moment to detect a new agent)
#   --wait        poll until someone is blocked or everyone has settled
#
# Exit codes:
#   0  everyone settled (idle / done / unknown), or --registered succeeded
#   2  --wait hit its timeout while agents were still working; call again
#   3  at least one agent is blocked and needs a human answer
#   1  usage error, herdr error, or --registered timed out
#
# The default --wait timeout stays under Claude Code's 120s Bash timeout so the call
# returns on its own instead of being killed. Re-invoke while it exits 2.
#
# This always re-reads `herdr agent list`. herdr's pane ids compact when panes close, and
# `herdr agent wait` is edge-triggered, so a missed transition never fires again.
set -euo pipefail

mode="snapshot"
timeout=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --wait) mode="wait"; shift ;;
    --registered) mode="registered"; shift ;;
    --timeout) timeout=$2; shift 2 ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

# Resolve the default after parsing so --timeout wins regardless of flag order.
if [ -z "$timeout" ]; then
  case "$mode" in
    registered) timeout=60 ;;
    *) timeout=100 ;;
  esac
fi

if [ "$#" -eq 0 ]; then
  echo "usage: agent-status.sh [--registered|--wait] [--timeout SECONDS] <agent-name>..." >&2
  exit 1
fi

snapshot() {
  herdr agent list | python3 -c '
import json, sys

wanted = sys.argv[1:]
known = {}
for agent in json.load(sys.stdin)["result"]["agents"]:
    name = agent.get("name")
    if name:
        known[name] = agent

for name in wanted:
    agent = known.get(name)
    if agent is None:
        print("\t".join([name, "missing", "-"]))
        continue
    print("\t".join([name, agent.get("agent_status") or "unknown", agent["pane_id"]]))
' "$@"
}

has_status() {
  awk -F'\t' -v want="$1" '$2 == want { found = 1 } END { exit !found }'
}

has_pending() {
  awk -F'\t' '$2 == "working" || $2 == "missing" { found = 1 } END { exit !found }'
}

deadline=$((SECONDS + timeout))

case "$mode" in
  snapshot)
    snapshot "$@"
    ;;
  registered)
    while :; do
      out=$(snapshot "$@")
      if ! printf '%s\n' "$out" | has_status missing; then
        printf '%s\n' "$out"
        exit 0
      fi
      if [ "$SECONDS" -ge "$deadline" ]; then
        printf '%s\n' "$out"
        echo "agent did not register within ${timeout}s" >&2
        exit 1
      fi
      sleep 1
    done
    ;;
  wait)
    while :; do
      out=$(snapshot "$@")
      if printf '%s\n' "$out" | has_status blocked; then
        printf '%s\n' "$out"
        exit 3
      fi
      if ! printf '%s\n' "$out" | has_pending; then
        printf '%s\n' "$out"
        exit 0
      fi
      if [ "$SECONDS" -ge "$deadline" ]; then
        printf '%s\n' "$out"
        exit 2
      fi
      sleep 2
    done
    ;;
esac
