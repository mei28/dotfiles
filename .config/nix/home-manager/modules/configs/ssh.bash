# ssh helpers. Sourced from .bashrc.
# ssh() wraps the real ssh with port-forward shorthand (lpt) and tmux pane
# labelling. lpt() is usable on its own.

# 独立したポート展開関数
# port token を -L に展開。 形式: [local:]remote[@host]
# 例: lpt 6006 8888        -> -L 6006:localhost:6006 -L 8888:localhost:8888
#     lpt 8222@fcdgx00223  -> -L 8222:fcdgx00223:8222      (worker node 転送)
#     lpt 18222:8222@node  -> -L 18222:node:8222           (local≠remote + worker)
function lpt() {
    local result=()
    for spec in "$@"; do
        local host="localhost" lp rp
        if [[ "$spec" == *"@"* ]]; then
            host="${spec##*@}"
            spec="${spec%@*}"
        fi
        if [[ "$spec" == *":"* ]]; then
            lp="${spec%%:*}"
            rp="${spec##*:}"
        else
            lp="$spec"
            rp="$spec"
        fi
        result+=("-L" "${lp}:${host}:${rp}")
    done
    echo "${result[@]}"
}

# ssh tmux lpt
function ssh() {
    local final_args=()
    local ports_to_process=()
    local target=""

    # エスケープシーケンス（echo -e 用）
    local C_CYAN='\e[36m'
    local C_GREEN='\e[32m'
    local C_YELLOW='\e[33m'
    local C_RESET='\e[0m'

    # 引数をループして、数字はlpt用にストック、それ以外は通常引数として扱う
    for arg in "$@"; do
        if [[ "$arg" =~ ^[0-9]+(:[0-9]+)?(@[A-Za-z0-9._-]+)?$ ]]; then
            ports_to_process+=("$arg")
        else
            # AWS のコンソールからコピペしたコマンドは root@host になっている。
            # 実行前にログインユーザを聞き直す (root のままにしたいなら root と打つ)。
            if [[ "$arg" == root@* ]]; then
                local login_host="${arg#root@}"
                local login_user=""
                read -e -r -p "login user for ${login_host}: " login_user
                if [[ -z "$login_user" ]]; then
                    echo "ssh: login user is empty" >&2
                    return 1
                fi
                arg="${login_user}@${login_host}"
            fi
            final_args+=("$arg")
            target="$arg" # 最後に現れた非数値引数をホスト名とみなす
        fi
    done

    # ポートが指定されていれば lpt で展開して引数の先頭に追加
    if [[ ${#ports_to_process[@]} -gt 0 ]]; then
        # lpt は "-L a:b:c -L d:e:f" を1行で返すので、配列に読み直して渡す
        local expanded_ports=()
        read -r -a expanded_ports <<< "$(lpt "${ports_to_process[@]}")"
        set -- "${expanded_ports[@]}" "${final_args[@]}"
    else
        set -- "${final_args[@]}"
    fi

    # 実行コマンドの表示（シアンとグリーンで見やすく）
    # 接続先(target)をイエローで強調します
    echo -e "${C_CYAN}[SSH Tunneling]${C_RESET} Executing: ${C_GREEN}ssh${C_RESET} $* (${C_YELLOW}${target}${C_RESET})"

    # --- tmux ロジック ---
    if [[ -n "${TMUX:-}" ]]; then
        local pane_id
        pane_id=$(tmux display -p '#{pane_id}')

        # 判定は抽出した target を使用
        local loopback_re='localhost|127\.0\.0\.1'
        if [[ "$target" =~ $loopback_re ]]; then
            tmux select-pane -P 'fg=#00BCD4,bg=#263238'
        else
            tmux select-pane -P 'fg=#CDDC39,bg=#263238'
        fi
        tmux select-pane -T "$target"

        command ssh "$@"
        tmux select-pane -t "$pane_id" -P 'default'
    else
        command ssh "$@"
    fi
}
