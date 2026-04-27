# Set PATH, MANPATH, etc., for Homebrew.
if [ -e /opt/homebrew/bin/brew ]
then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
if type nix &> /dev/null; then
    export PATH="~/.nix-profile/bin:$PATH"
fi

# .bashrc
#========#
# COMMON #
#========#

# git jump
# git highlight
if [ -e ~/.nix-profile/share/git/contrib ]; then
    export GIT_CONTRIB_PATH=~/.nix-profile/share/git/contrib
elif [ -e /usr/local/share/git-core/contrib ]; then
    export GIT_CONTRIB_PATH=/usr/local/share/git-core/contrib
elif [ -e /opt/homebrew/share/git-core/contrib ]; then
    export GIT_CONTRIB_PATH=/opt/homebrew/share/git-core/contrib
elif [ -e /usr/share/doc/git/contrib ]; then
    export GIT_CONTRIB_PATH=/usr/share/git/contrib
fi

export PATH="$PATH:$GIT_CONTRIB_PATH/git-jump"
export PATH="$PATH:$GIT_CONTRIB_PATH/diff-highlight"

# prompt
if [ -e $GIT_CONTRIB_PATH/completion/git-prompt.sh ]; then
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWSTASHSTATE=true
    GIT_PS1_SHOWUPSTREAM=auto
    source $GIT_CONTRIB_PATH/completion/git-prompt.sh
    GIT_PROMPT_EXIST=true
else
    GIT_PROMPT_EXIST=false
fi


replace_home_with_tilde() {
    local path="$1"
    local home="$HOME"

    if [[ "$path" == "$home"* ]]; then
        echo "~${path#$home}"
    else
        echo "$path"
    fi
}

function shorten_path {
    local path=$(replace_home_with_tilde "$PWD")
    local max_len=20
    local path_len=${#path}

    if (( path_len <= max_len )); then
        echo "$path"
        return
    fi

    local IFS='/'
    read -ra segments <<< "$path"

    local new_segments=("${segments[@]}")
    local total_len=$path_len
    local last_index=$(( ${#segments[@]} - 1 ))

    for (( i=1; i<last_index; i++ )); do
        if (( total_len <= max_len )); then
            break
        fi
        local original_len=${#new_segments[i]}
        local shortened_len=3
        new_segments[i]="${new_segments[i]:0:$shortened_len}"
        total_len=$(( total_len - original_len + shortened_len ))
    done

    local shortened_path
    shortened_path=$(IFS='/'; echo "${new_segments[*]}")

    echo "$shortened_path"
}

# Define color variables
RESET='\[\e[0m\]'
BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
MAGENTA='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
WHITE='\[\e[0;37m\]'

# Bold colors
BOLD_BLACK='\[\e[1;30m\]'
BOLD_RED='\[\e[1;31m\]'
BOLD_GREEN='\[\e[1;32m\]'
BOLD_YELLOW='\[\e[1;33m\]'
BOLD_BLUE='\[\e[1;34m\]'
BOLD_MAGENTA='\[\e[1;35m\]'
BOLD_CYAN='\[\e[1;36m\]'
BOLD_WHITE='\[\e[1;37m\]'

# Background colors
BG_YELLOW='\[\e[43m\]'

function set_prompt {
    local ps1_prefix=""
    local ps1_suffix=""
    path=$(shorten_path)

    if $GIT_PROMPT_EXIST; then
        ps1_suffix="${BLUE}${path} ${GREEN}$(__git_ps1 "(%s)")${WHITE}\$${RESET} "
    else
        ps1_suffix="${BLUE}${path} ${WHITE}\$${RESET} "
    fi

    if [[ ! -z $SSH_CONNECTION ]]; then
        ps1_prefix="${BOLD_BLACK}${BG_YELLOW} SSH ${RESET} "
    fi

    if [ -f /.dockerenv ]; then
        ps1_prefix="${ps1_prefix}${BOLD_BLUE}🐳${RESET}"
    fi

    if [[ -n "$VIRTUAL_ENV" ]]; then
        ps1_prefix="(`basename \"$VIRTUAL_ENV\"`)"$ps1_prefix
    fi

    if [[ -n "$IN_NIX_SHELL" && "$IN_NIX_SHELL" == "impure" ]]; then
        ps1_prefix="${ps1_prefix}${BOLD_GREEN}🧊${RESET} "
    fi

    # WezTerm Shell Integration: OSC 133 markers
    if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
        local osc_prompt_start='\[\033]133;A\007\]'
        local osc_input_start='\[\033]133;B\007\]'
        PS1="${osc_prompt_start}${ps1_prefix}${ps1_suffix}${osc_input_start}"
    else
        PS1="${ps1_prefix}${ps1_suffix}"
    fi
}


function add_line {
    if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
        PS1_NEWLINE_LOGIN=true
    else
        printf '\n'
    fi
}

# WezTerm Shell Integration: OSC 133;D (command end) and OSC 133;C (command start)
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    __wezterm_osc() { printf "\033]%s\007" "$1"; }

    __wezterm_cmd_executed=""

    __wezterm_precmd() {
        local exit_code=$?
        if [[ -n "$__wezterm_cmd_executed" ]]; then
            __wezterm_osc "133;D;$exit_code"
        fi
        __wezterm_cmd_executed=""
    }

    __wezterm_preexec() {
        [[ -n "$COMP_LINE" ]] && return
        [[ "$BASH_COMMAND" == *"__wezterm_"* ]] && return
        [[ "$BASH_COMMAND" == "set_prompt"* ]] && return
        [[ "$BASH_COMMAND" == "add_line"* ]] && return
        if [[ -z "$__wezterm_cmd_executed" ]]; then
            __wezterm_osc "133;C"
            __wezterm_cmd_executed="1"
        fi
    }

    trap '__wezterm_preexec' DEBUG
    PROMPT_COMMAND='__wezterm_precmd; set_prompt; add_line'
else
    PROMPT_COMMAND='set_prompt; add_line'
fi

# git completion
if [ -e $HOME/.git-completion.bash ]
then
    source $HOME/.git-completion.bash
fi

if [ -e $HOME/.y/bin ]; then
    export PATH="$HOME/.y/bin:$PATH"
fi
if [ -e $HOME/.config/yarn/global/node_modules/.bin ]; then
    export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi
# export PATH="$HOME/.y/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# export PATH="/usr/local/bin/git:$PATH"



# nvim
alias nv='nvim'
alias gv='nvim'
alias vn='nvim'
alias nn='export NVIM_APPNAME=nvim; nvim'
alias nvc='nvim --clean'
alias nvi='export NVIM_APPNAME=nvim-minimal; nvim'

# if [ -e $HOME/.nvm ]; then
#     export NVM_DIR="$HOME/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#     [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# fi

if type npm &> /dev/null; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# mkdir and change directory
mkcd(){
    mkdir -p $1 && cd $1 && pwd
}


# ruby env
if [ -e ~/.rbenv/shims ]; then
    export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
    if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
fi

# rust env  for rust
if [[ -f $HOME/.cargo/env ]]; then
    source $HOME/.cargo/env
    # export PATH="$HOME/.cargo/bin:$PATH"
    # export PATH="$HOME/.rustup/toolchains/nightly-aarch64-apple-darwin/bin:$PATH"
fi

# pyenv env
if [ -e $HOME/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# if which pyenv > /dev/null; then eval "$(pyenv init --path)"; fi
# eval "$(pyenv init --path)"
# eval "$(pyenv virtualenv-init -)"

actpyenv(){
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
    echo "activate pyenv!!"
}



# clang for nvim, c++
# brew install llvm
if [ -d /usr/local/opt/llvm ]; then
    export PATH="/usr/local/opt/llvm/bin:$PATH"
fi
if [ -d /opt/homebrew/opt/llvm ]; then
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
    export LLVM_SYMBOLIZER_PATH=/opt/homebrew/opt/llvm/bin/llvm-symbolizer
fi



## activate virtualenv
if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
    source "${VIRTUAL_ENV}/bin/activate"
fi


## activate virtualenv
## suggest the function name below
function actvenv() {
    venv_path=$(find . -maxdepth 2 -type d -name "bin" -exec test -e '{}/activate' ';' -print -quit | sed 's/\/bin//g')
    if [ -z "$venv_path" ]; then
        echo "No Python virtual environment found in the current directory."
    else
        echo "Activating $venv_path"
        source "$venv_path/bin/activate"
    fi
}

# toggle virtualenv
function toggle_virtualenv(){
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo "Deactivating virtual environment..."
        deactivate
    else
        venv_path=$(find . -maxdepth 2 -type d -name "bin" -exec test -e '{}/activate' ';' -print -quit | sed 's/\/bin//g')
        if [ -z "$venv_path" ]; then
            echo "No Python virtual environment found in the current directory."
        else
            echo "Activating $venv_path"
            source "$venv_path/bin/activate"
        fi
    fi
}

alias tv="toggle_virtualenv"




## rm alias
if type trash-put &> /dev/null
then
    alias rm=trash-put
fi

# deno
if [ -e $HOME/.deno ]; then
    export DENO_INSTALL="/home/mei/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi


# pytest
alias pt='pytest -s'


# compile c++
cgpp(){
    g++ -std=gnu++17 -Wall -Wextra -O2 -o ./a.out $1
    echo '----------'
    ./a.out
}

# cd..
alias cd..="cd .."
# cd-
alias cd-="cd -"

# shutdown
alias shutdownnow="sudo shutdown -h +1"

# restart
alias restartnow="sudo shutdown -r +1"

# 独立したポート展開関数
# 使い方: lpt 6006 8888 -> -L 6006:localhost:6006 -L 8888:localhost:8888
function lpt() {
    local result=()
    for port in "$@"; do
        result+=("-L" "$port:localhost:$port")
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
        if [[ "$arg" =~ ^[0-9]+$ ]]; then
            ports_to_process+=("$arg")
        else
            final_args+=("$arg")
            target="$arg" # 最後に現れた非数値引数をホスト名とみなす
        fi
    done

    # ポートが指定されていれば lpt で展開して引数に追加
    if [[ ${#ports_to_process[@]} -gt 0 ]]; then
        # 展開された文字列を配列として結合
        local expanded_ports=$(lpt "${ports_to_process[@]}")
        # Note: ここでは単純に args の先頭に追加
        set -- $(lpt "${ports_to_process[@]}") "${final_args[@]}"
    else
        set -- "${final_args[@]}"
    fi

    # 実行コマンドの表示（シアンとグリーンで見やすく）
    # 接続先(target)をイエローで強調します
    echo -e "${C_CYAN}[SSH Tunneling]${C_RESET} Executing: ${C_GREEN}ssh${C_RESET} $@ (${C_YELLOW}${target}${C_RESET})"

    # --- tmux ロジック ---
    if [[ -n $(printenv TMUX) ]] ; then
        local pane_id=`tmux display -p '#{pane_id}'`
        
        # 判定は抽出した target を使用
        if [[ "$target" =~ "localhost|127\.0\.0\.1" ]] ; then
            tmux select-pane -P 'fg=#00BCD4,bg=#263238'
        else
            tmux select-pane -P 'fg=#CDDC39,bg=#263238'
        fi
        tmux select-pane -T "$target"

        command ssh "$@"
        tmux select-pane -t $pane_id -P 'default'
    else
        command ssh "$@"
    fi
}

# z command
if type zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi


# fzf activate key-bindings
if [ -e  ~/.nix-profile/share/fzf/key-bindings.bash ]; then
    source ~/.nix-profile/share/fzf/key-bindings.bash
fi

if type gh &> /dev/null; then
    eval "$(gh completion -s bash)"
fi

if [ -e ~/.openai ]; then
    export OPENAI_API_KEY=`cat ~/.openai`
fi

alias ruge="cargo generate --git https://github.com/mei28/rust-comp-template"

export PATH="$PATH:/Users/mei/.bin"

if [ -e $HOME/.rye  ]; then
    source "$HOME/.rye/env"
    eval "$(rye self completion -s bash)"
fi

if [ -e $HOME/.config/uv ]; then
    eval "$(uv generate-shell-completion bash)"
fi

if [ -e $HOME/go/bin ]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# show completion
if [[ -t 1 ]]; then
    bind 'set show-all-if-ambiguous on'
fi

# tmux
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

function tmux() {
    if [ $# -eq 0 ]; then
        tmux attach -t default || tmux new -s default
    else
        command tmux "$@"
    fi
}


function kmux() {
    tmux kill-server
    echo "Kill tmux server"
}
function dmux() {
    tmux detach-client
    echo "detach tmux client"
}

if type tmux &> /dev/null; then
    tcap() {
        if [ -z "$TMUX" ]; then
            echo "Error: Not in a tmux session" >&2
            return 1
        fi
        tmux capture-pane -p | nvim -R -
    }
fi
# ヒストリーの削除
export HISTCONTROL=ignoreboth

if [[ -e "$HOME/.modular" ]]; then
    export MODULAR_HOME="$HOME/.modular"
    export PATH="$MODULAR_HOME/pkg/packages.modular.com_mojo/bin:$PATH"
fi


# obsidian
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

if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi


if type gitui &> /dev/null;
then
    alias gu='gitui'
fi

if type jj &> /dev/null;
then
    (jj util completion bash) > /tmp/jj_completion.sh
    source /tmp/jj_completion.sh

    jjb() {
        if [ $# -eq 0 ]; then
            echo "Usage: jjb <branch>"
            return 1
        fi
        jj bookmark set -r @- "$1"
    }
fi


if type wezterm  &> /dev/null;
then
    alias imgcat='wezterm imgcat'
    eval "$(wezterm shell-completion --shell bash)"
    ln -snf ~/.config/wezterm/wezterm.lua ~/.wezterm.lua
fi


# sudo completion
complete -cf sudo
alias sudo='sudo '


# oj
if [[ -f ~/Documents/competitive-programing/scripts/oj_d.sh ]]; then
    source ~/Documents/competitive-programing/scripts/oj_d.sh
fi
if [[ -f ~/Documents/competitive-programing/scripts/oj_t.sh ]]; then
    source ~/Documents/competitive-programing/scripts/oj_t.sh
fi
if [[ -f ~/Documents/competitive-programing/scripts/oj_s.sh ]]; then
    source ~/Documents/competitive-programing/scripts/oj_s.sh
fi

# yazi
if type yazi &> /dev/null; then
    function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# https://x.com/walnuts1018/status/1839636079164715262?s=46&t=CQvD0ppkcFnFEeBoG47BZg
# alias "$"=""

export PNPM_HOME="/Users/mei/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if type pnpm &> /dev/null; then
    eval "$(pnpm completion bash)"
fi


# docker completion
if type docker &> /dev/null; then
    eval "$(docker completion bash)"
fi

# git graph serie
if type serie &> /dev/null; then
    alias gl='serie'
fi



# if [[ -f ~/.config/nix/completions/nix.bash ]]; then
#     source ~/.config/nix/completions/nix.bash
# fi

# cliperge
if type cliperge &> /dev/null; then
    alias cl='cliperge'
    alias cr='cliperge -r'
fi

# fzf-make
if type fzf-make &> /dev/null; then
    alias fm='fzf-make'
    alias fr='fzf-make repeat'
    alias fh='fzf-make history'
fi

# Prevent committing unresolved conflict markers
git() {
    if [[ "$1" == "commit" ]]; then
        local files_with_markers=()
        while IFS= read -r file; do
            if command git show ":$file" 2>/dev/null | grep -qE '^(<{7}|>{7}) '; then
                files_with_markers+=("$file")
            fi
        done < <(command git diff --cached --name-only --diff-filter=ACMR)

        if [[ ${#files_with_markers[@]} -gt 0 ]]; then
            echo "Error: Conflict markers detected. Commit aborted." >&2
            printf '  %s\n' "${files_with_markers[@]}" >&2
            return 1
        fi
    fi
    command git "$@"
}

# go to git root
alias gr='cd $(git rev-parse --show-toplevel)'

## git branch delete
alias gbd="git branch --merged | grep -vE '\\*\\|main' | xargs git branch -d"


## portsage
if type portsage &> /dev/null; then
    alias psa='portsage'
fi

## ccusage
if type ccusage &> /dev/null; then
    alias ccu='ccusage'
    alias ccl='ccusage blocks --live'
fi

if type claude &> /dev/null; then
    export EDITOR="nvim"
    export CLAUDE_CODE_EFFORT_LEVEL="xhigh";
fi

if type git-gardener &> /dev/null; then
    alias ggr='git-gardener'
fi

# Function to omit '%' for the fg command
fg() {
    # If there's an argument, run with '%', otherwise run as is
    if [ -n "$1" ]; then
        builtin fg %"$1"
    else
        builtin fg
    fi
}

# Do the same for the bg command
bg() {
    if [ -n "$1" ]; then
        builtin bg %"$1"
    else
        builtin bg
    fi
}

# A custom function to list jobs and resume one
jb() {
    # First, list the current jobs.
    # Using 'jobs -l' is clearer as it shows the process ID.
    jobs -l

    # If there are no jobs, exit the function here.
    if ! jobs &>/dev/null; then
        return
    fi

    # Prompt the user for input and wait.
    # The 'read' command stores the input in the 'job_num' variable.
    read -p "Enter job number to resume (or Enter to cancel): " job_num

    # Only run the fg command if a number was entered.
    if [[ -n "$job_num" ]]; then
        builtin fg %"$job_num"
    fi
}

jk() {
    # showing process IDs can help users identify which job they want to kill
    jobs -l

    # If there are no jobs, exit the function here.
    if ! jobs &>/dev/null; then
        return
    fi

    # promote user to enter the job number to kill
    read -p "Enter job number to kill (or Enter to cancel):" job_num

    # If a number was entered, run the kill command
    if [[ -n "$job_num" ]]; then
        kill %"$job_num"
    fi
}

if type bun &> /dev/null; then
    export PATH="/Users/mei/.bun/bin:$PATH"
fi

# clipboard helper: reads from stdin and copies to clipboard
_copy_to_clipboard() {
    if command -v pbcopy >/dev/null 2>&1; then
        pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --input
    else
        # OSC52: terminal escape sequence for clipboard
        local data
        data=$(base64 | tr -d '\n')
        if [[ -n "$TMUX" ]]; then
            printf '\ePtmux;\e\e]52;c;%s\a\e\\' "$data"
        else
            printf '\e]52;c;%s\a' "$data"
        fi
    fi
}

# copy file content to clipboard
pbc() {
    if [ -f "$1" ]; then
        _copy_to_clipboard < "$1"
        echo "Copied $1!!"
    else
        echo "Error: File '$1' does not exist."
        return 1
    fi
}

# copy pwd to clipboard
cpwd() {
    pwd | _copy_to_clipboard
    echo "Copied to clipboard: $(pwd)"
}


if [ -f ~/.bashrc.local ]; then
  . ~/.bashrc.local
fi

if type claude &> /dev/null; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if type bonsai &> /dev/null; then
  eval "$(bonsai completion bash)"
  eval "$(bonsai shell-init bash)"
fi

# if type intelli-shell &> /dev/null; then
#     eval "$(intelli-shell init bash)"
#     export INTELLI_SEARCH_HOTKEY="\C-o"
#     export INTELLI_BOOKMARK_HOTKEY=""
#     export INTELLI_VARIABLE_HOTKEY=""
#     bind -x '"\C-o": "intelli-shell search -i"'
# fi

#=====================#
# change config by OS #
#=====================#

case ${OSTYPE} in
    darwin*)
        if [ -f ~/.config/nix/home-manager/modules/configs/.bashrc.darwin ]; then
            . ~/.config/nix/home-manager/modules/configs/.bashrc.darwin
        fi
        ;;
    linux*)
        if [ -f ~/.config/nix/home-manager/modules/configs/.bashrc.linux ]; then
            . ~/.config/nix/home-manager/modules/configs/.bashrc.linux
        fi
        ;;
esac

#==========#
