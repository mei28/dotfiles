# Bash completion for herdr and hdr.
# Parses the installed herdr help output so new subcommands are reflected without
# keeping a static command list here.

__herdr_complete_words() {
    COMPREPLY=( $(compgen -W "$1" -- "$2") )
}

__herdr_help() {
    command herdr "$@" --help 2>&1
}

__herdr_command_path=()
__herdr_set_command_path() {
    __herdr_command_path=()
    if [ "$COMP_CWORD" -gt 1 ] && [[ -n "${COMP_WORDS[1]}" && "${COMP_WORDS[1]}" != -* ]]; then
        __herdr_command_path=("${COMP_WORDS[1]}")
    fi
    if [ "$COMP_CWORD" -gt 2 ] && [ "${#__herdr_command_path[@]}" -eq 1 ] &&
        [[ -n "${COMP_WORDS[2]}" && "${COMP_WORDS[2]}" != -* ]]; then
        __herdr_command_path+=("${COMP_WORDS[2]}")
    fi
}

__herdr_prefix() {
    local prefix="herdr" word
    for word in "${__herdr_command_path[@]}"; do
        prefix="$prefix $word"
    done
    printf '%s\n' "$prefix"
}

__herdr_help_args() {
    if [ "${#__herdr_command_path[@]}" -eq 0 ]; then
        return
    fi
    if [ "${#__herdr_command_path[@]}" -eq 1 ]; then
        printf '%s\n' "${__herdr_command_path[0]}"
        return
    fi
    printf '%s\n' "${__herdr_command_path[0]}"
}

__herdr_dynamic_words() {
    local help="$1" prefix="$2"
    printf '%s\n' "$help" |
        awk -v prefix="$prefix" '
            BEGIN {
                prefix_count = split(prefix, prefix_parts, /[[:space:]]+/)
            }
            function emit(value) {
                gsub(/^[\[<(]+/, "", value)
                gsub(/[\]>),]+$/, "", value)
                if (value == "" || value ~ /^--/) return
                if (value !~ /^[A-Za-z0-9][A-Za-z0-9-]*$/) return
                if (value ~ /^[A-Z]/) return
                if (value ~ /^[A-Z_]+$/) return
                if (value ~ /_id$/ || value ~ /_path$/) return
                if (value ~ /^(id|name|target|text|command|label|path|ref|key|value)$/) return
                if (!seen[value]++) print value
            }
            {
                line = $0
                sub(/^[[:space:]]*usage:[[:space:]]*/, "", line)
                sub(/^[[:space:]]+/, "", line)
                if (line !~ /^herdr([[:space:]]|$)/) next
                split(line, parts, /[[:space:]]+/)
                for (i = 1; i <= prefix_count; i++) {
                    if (parts[i] != prefix_parts[i]) next
                }
                token = parts[prefix_count + 1]
                if (token == "" || token ~ /^-/ || token ~ /^\[?--/) next
                if (token ~ /\|/) {
                    choice_count = split(token, choices, /\|/)
                    for (i = 1; i <= choice_count; i++) emit(choices[i])
                } else {
                    if (token ~ /^</) next
                    emit(token)
                }
            }
        '
}

__herdr_dynamic_options() {
    local help="$1" prefix="$2"
    printf '%s\n' "$help" |
        awk -v prefix="$prefix" '
            BEGIN {
                prefix_count = split(prefix, prefix_parts, /[[:space:]]+/)
            }
            function emit_options(text) {
                while (match(text, /(^|[[:space:]\[|,])-{1,2}[A-Za-z0-9][A-Za-z0-9-]*/)) {
                    option = substr(text, RSTART, RLENGTH)
                    gsub(/^[[:space:]\[|,]+/, "", option)
                    if (!seen[option]++) print option
                    text = substr(text, RSTART + RLENGTH)
                }
            }
            function matches_prefix(text, parts, i) {
                split(text, parts, /[[:space:]]+/)
                for (i = 1; i <= prefix_count; i++) {
                    if (parts[i] != prefix_parts[i]) return 0
                }
                return 1
            }
            {
                line = $0
                sub(/^[[:space:]]*usage:[[:space:]]*/, "", line)
                sub(/^[[:space:]]+/, "", line)
                if (line ~ /^herdr([[:space:]]|$)/) {
                    if (matches_prefix(line)) emit_options(line)
                } else if (prefix == "herdr" && line ~ /^-/) {
                    emit_options(line)
                }
            }
        '
}

__herdr_dynamic_option_values() {
    local help="$1" prefix="$2" option="$3"
    printf '%s\n' "$help" |
        awk -v prefix="$prefix" -v option="$option" '
            BEGIN {
                prefix_count = split(prefix, prefix_parts, /[[:space:]]+/)
            }
            function emit(value, choices, i) {
                gsub(/^[\[<(]+/, "", value)
                gsub(/[\]>),]+$/, "", value)
                if (value !~ /\|/) return
                choice_count = split(value, choices, /\|/)
                for (i = 1; i <= choice_count; i++) {
                    gsub(/^[\[<(]+/, "", choices[i])
                    gsub(/[\]>),]+$/, "", choices[i])
                    if (choices[i] == "" || choices[i] ~ /^--/) continue
                    if (!seen[choices[i]]++) print choices[i]
                }
            }
            function matches_prefix(text, parts, i) {
                split(text, parts, /[[:space:]]+/)
                for (i = 1; i <= prefix_count; i++) {
                    if (parts[i] != prefix_parts[i]) return 0
                }
                return 1
            }
            function scan(text, parts, i) {
                part_count = split(text, parts, /[[:space:]]+/)
                for (i = 1; i <= part_count; i++) {
                    if (parts[i] == option) emit(parts[i + 1])
                }
            }
            {
                line = $0
                sub(/^[[:space:]]*usage:[[:space:]]*/, "", line)
                sub(/^[[:space:]]+/, "", line)
                if (line ~ /^herdr([[:space:]]|$)/) {
                    if (matches_prefix(line)) scan(line)
                } else if (prefix == "herdr" && line ~ /^-/) {
                    scan(line)
                }
            }
        '
}

__herdr_completion() {
    local cur prev prefix help words options values
    local help_args=()

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    __herdr_set_command_path
    prefix="$(__herdr_prefix)"
    while IFS= read -r word; do
        [ -n "$word" ] && help_args+=("$word")
    done < <(__herdr_help_args)
    help="$(__herdr_help "${help_args[@]}")"

    if [[ "$prev" == --* ]]; then
        values="$(__herdr_dynamic_option_values "$help" "$prefix" "$prev")"
        [ -n "$values" ] && __herdr_complete_words "$values" "$cur"
        return 0
    fi

    if [[ "$cur" == -* ]]; then
        options="$(__herdr_dynamic_options "$help" "$prefix")"
        __herdr_complete_words "$options" "$cur"
        return 0
    fi

    words="$(__herdr_dynamic_words "$help" "$prefix")"
    __herdr_complete_words "$words" "$cur"
}

if type herdr &> /dev/null; then
    complete -F __herdr_completion herdr hdr
fi
