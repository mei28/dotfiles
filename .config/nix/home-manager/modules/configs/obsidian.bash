# Obsidian daily-note helpers (ot / obm). Superseded by org.bash.
# Writes to ~/Documents/ovault/vault, which was last used 2025-02.
# Disabled in .bashrc; uncomment the source line there to bring ot/obm back.

function createDailyFileIfNeeded() {
    local target_dir="$HOME/Documents/ovault/vault"
    local today=$(date +"%Y-%m-%d")
    local file_path="$target_dir/$today.md"

    mkdir -p "$target_dir" # ディレクトリが存在しない場合は作成

    if [ ! -f "$file_path" ]; then
        # ファイルが存在しない場合は新規作成
        cat > "$file_path" <<- EOM
---
id: $today
aliases:
  - $(date +"%B %d, %Y")
tags:
  - daily-notes
---

# $(date +"%B %d, %Y")
EOM
    fi
    echo "$file_path"
}

function ot() {
    local file_path=$(createDailyFileIfNeeded)
    nvim "$file_path" # nvimでファイルを開く
}

function obm() {
    local file_path=$(createDailyFileIfNeeded)

    local time_stamp=$(date +"[%H:%M]")
    local last_time_stamp=$(grep "\[$(date +"%H:%M")\]" "$file_path")

    if [ -z "$last_time_stamp" ]; then
        echo "" >> "$file_path"
        echo "$time_stamp" >> "$file_path"
    fi

    echo "$*" >> "$file_path"
}
