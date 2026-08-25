# Sleep-prevention helpers. Sourced from .bashrc.darwin (macOS only).
#
# cafwake holds a PreventUserIdleSystemSleep assertion so that locking the screen
# (cmd+ctrl+q) leaves network connections and long-running jobs alive. The
# display still sleeps and the screen still locks -- only idle *system* sleep is
# suppressed, which is what -i buys and why -d is deliberately absent.
#
# Closing the lid still sleeps the machine: clamshell sleep is not an idle sleep
# and no assertion can hold it off. Keep the lid open, or dock to an external
# display on AC.
#
# Hammerspoon (.hammerspoon/caffeine.lua) does the same thing automatically on
# screen lock. These two are independent assertions and stack harmlessly; cafwake
# covers the case of a long job running while the screen stays unlocked.

CAFWAKE_DEFAULT_DURATION="${CAFWAKE_DEFAULT_DURATION:-12h}"

_cafwake_pidfile() {
    printf '%s\n' "${CAFWAKE_PIDFILE:-${TMPDIR:-/tmp}/cafwake.pid}"
}

# "12h" / "90m" / "45s" / bare seconds -> seconds. Anything else is an error.
_cafwake_seconds() {
    local spec="$1" value unit
    if [[ ! "$spec" =~ ^([0-9]+)([hms]?)$ ]]; then
        echo "cafwake: invalid duration [$spec] (use 12h, 90m, 45s, or plain seconds; see: cafwake help)" >&2
        return 1
    fi
    value="${BASH_REMATCH[1]}"
    unit="${BASH_REMATCH[2]}"
    case "$unit" in
        h) printf '%s\n' "$((value * 3600))" ;;
        m) printf '%s\n' "$((value * 60))" ;;
        *) printf '%s\n' "$value" ;;
    esac
}

_cafwake_human() {
    local seconds="$1"
    printf '%dh%02dm\n' "$((seconds / 3600))" "$(((seconds % 3600) / 60))"
}

# Echoes "<pid> <deadline>" and returns 0 only while the assertion really holds.
# Releases and forgets it otherwise, so every caller sees one consistent state.
_cafwake_live() {
    local pidfile pid deadline
    pidfile="$(_cafwake_pidfile)"
    [[ -f "$pidfile" ]] || return 1

    read -r pid deadline <"$pidfile"
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pidfile"
        return 1
    fi
    # The deadline, not caffeinate's own timer, is authoritative: that timer does
    # not advance across system sleep, so a 12h assertion can outlive 12h of wall
    # clock after a suspend.
    if [[ "$(date +%s)" -ge "$deadline" ]]; then
        kill "$pid" 2>/dev/null
        rm -f "$pidfile"
        return 1
    fi
    printf '%s %s\n' "$pid" "$deadline"
}

_cafwake_help() {
    cat <<'HELP'
cafwake - hold off idle system sleep so a locked screen keeps jobs running

Usage:
  cafwake [duration]        Hold for duration, default 12h
  cafwake status            Report the current hold and time left
  cafwake off               Release the hold now
  cafwake help              Show this message

Duration:
  12h, 90m, 45s, or a plain number of seconds.

Behaviour:
  Re-running replaces the current hold instead of extending it, so the
  duration just typed is the one that applies.
  The hold outlives the shell that started it; closing the terminal is safe.
  Time is measured against the wall clock, so suspending the machine does not
  stretch the hold.

Limits:
  Closing the lid still sleeps the machine. Clamshell sleep is not an idle
  sleep and no assertion holds it off; keep the lid open, or dock to an
  external display on AC.
  The display still sleeps and the screen still locks. Only idle system sleep
  is suppressed.

See also:
  caf <command> [args...]   Hold only while that command runs.
  Locking the screen holds automatically (.hammerspoon/caffeine.lua), so
  cafwake is for jobs that run while the screen stays unlocked.
HELP
}

cafwake() {
    local pidfile pid deadline seconds
    pidfile="$(_cafwake_pidfile)"

    case "${1-}" in
        help | -h | --help)
            _cafwake_help
            return 0
            ;;
        status)
            if read -r pid deadline < <(_cafwake_live); then
                echo "cafwake: active, $(_cafwake_human "$((deadline - $(date +%s)))") remaining (pid $pid)"
                return 0
            fi
            echo "cafwake: inactive"
            return 1
            ;;
        off)
            if ! read -r pid deadline < <(_cafwake_live); then
                echo "cafwake: inactive" >&2
                return 1
            fi
            kill "$pid" 2>/dev/null
            rm -f "$pidfile"
            echo "cafwake: released (pid $pid)"
            return 0
            ;;
    esac

    seconds="$(_cafwake_seconds "${1-$CAFWAKE_DEFAULT_DURATION}")" || return 1

    # An explicit invocation always wins: drop whatever is held and restart, so
    # the duration just typed is the duration that applies.
    if read -r pid deadline < <(_cafwake_live); then
        kill "$pid" 2>/dev/null
    fi

    caffeinate -i -t "$seconds" &
    pid=$!
    disown "$pid" 2>/dev/null
    printf '%s %s\n' "$pid" "$(($(date +%s) + seconds))" >"$pidfile"
    echo "cafwake: holding for $(_cafwake_human "$seconds") (pid $pid)"
}

# Hold the assertion for exactly as long as a command runs.
caf() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: caf <command> [args...]" >&2
        return 2
    fi
    caffeinate -i "$@"
}
