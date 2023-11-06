# .bashrc
#========#
# COMMON #
#========#

# git jump
# git highlight
if [ -e /usr/local/share/git-core/contrib ]; then
    export GIT_CONTRIB_PATH=/usr/local/share/git-core/contrib
elif [ -e /opt/homebrew/share/git-core/contrib ]; then
    export GIT_CONTRIB_PATH=/opt/homebrew/share/git-core/contrib
elif [ -e /usr/share/doc/git/contrib ]; then
    export GIT_CONTRIB_PATH=/usr/share/doc/git/contrib
fi

export PATH="$PATH:$GIT_CONTRIB_PATH/git-jump"
export PATH="$PATH:$GIT_CONTRIB_PATH/diff-highlight"

# prompt
if [ -e $HOME/.git-prompt.sh ]
then
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWSTASHSTATE=true
    GIT_PS1_SHOWUPSTREAM=auto

    source $HOME/.git-prompt.sh
    PS1='\[\e[34m\]\w \[\e[0;32m\]$(__git_ps1 "(%s)")\[\e[0;37m\]\$\[\e[0m\] '

    if [[ ! -z $SSH_CONNECTION ]]; then
        PS1='\[\e[1;30;43m\] SSH \[\e[0m\]'\ $PS1
    fi

    if [ -f /.dockerenv ]; then
        PS1='\[\e[1;34m\]🐳\[\e[0m\] '$PS1
    fi
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


function add_line {
    if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
        PS1_NEWLINE_LOGIN=true
    else
        printf '\n'
    fi
}

PROMPT_COMMAND='add_line'

# nvim
alias nv='nvim'

if [ -e $HOME/.nvm ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# mkdir and change directory
mkcd(){
    mkdir -p $1 && cd $1 && pwd
}


# ruby env
if [ -e ~/.rbenv/shims ]; then
    export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

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

if which pyenv > /dev/null; then eval "$(pyenv init --path)"; fi
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
alias pt='pytest'


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

# ssh tmux
function ssh() {
    # tmux起動時
    if [[ -n $(printenv TMUX) ]] ; then
        # 現在のペインIDの退避と背景色の書き換え
        local pane_id=`tmux display -p '#{pane_id}'`
        # 接続先ホスト名に応じて背景色、文字色を切り替え
        if [[ `echo ${!#} | grep -E 'localhost|127\.0\.0\.1'` ]] ; then
            tmux select-pane -P 'fg=#00BCD4,bg=#263238'
        else
            tmux select-pane -P 'fg=#CDDC39,bg=#263238'
        fi
        tmux select-pane -T "${!#}"

        # 通常通りコマンド続行
        command ssh $@
        # デフォルトの色設定に戻す
        tmux select-pane -t $pane_id -P 'default'
    else
        command ssh $@
    fi
}

# z command
if type zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
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

#=====================#
# change config by OS #
#=====================#

#=====#
# MAC #
#=====#

case ${OSTYPE} in
    darwin*)
        # ls(color)
        alias ls='ls -G'
        alias ll='ls -lG'
        alias la='ls -laG'

        # bash_completion
        # Use bash-completion, if available


        # pbcopy for macOS
        pbc(){
            cat $1 | pbcopy && echo "Copied $1!!"
        }

        alias tdi='_toggle_desktop_icon'
        _toggle_desktop_icon(){
            local isDisplay=$(defaults read com.apple.finder CreateDesktop)
            if [ $isDisplay -eq 1 ]; then
                defaults write com.apple.finder CreateDesktop -boolean false && killall Finder
                echo "Hide Desktop Icon"
            else
                defaults write com.apple.finder CreateDesktop -boolean true && killall Finder
                echo "Show Desktop Icon"
            fi
        }

        ## add cmake
        if [ -e /Applications/CMake.app/Contents/bin ]; then
            export PATH="/Applications/CMake.app/Contents/bin:$PATH"
        fi

        ;;
        #========#
        # ubuntu #
        #========#
    linux*)
        # ls(color)
        alias ls='ls --color'
        alias ll='ls -l --color'
        alias la='ls -la --color'

        # open alias
        alias open='xdg-open'

        # bash-completion
        # if [ -f $(brew --prefix)/etc/bash_completion ]; then
        #   source $(brew --prefix)/etc/bash_completion
        # fi

        if [ -f /usr/local/share/bash-completion/bash_completion ]; then
            source /usr/share/bash-completion/bash_completion
        fi

        # pbcopy for linux
        pbc(){
            cat $1 | xsel --clipboard --input && echo "Copied $1!!"
        }

        # cuda
        export PATH="/usr/local/cuda/bin:$PATH"
        export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

        # suspend
        alias suspend='systemctl suspend'

        # powertop auto tune
        alias powtune='sudo powertop --auto-tune'
        alias powtop='sudo powertop'

        # wezterm
        alias wezterm='flatpak run org.wezfurlong.wezterm'

        # # quicktile
        # if [ -f ~/.config/quicktile.cfg ]; then
        #     ret=`ps aux | grep "quicktile --daemonize" | grep -v grep | wc -l`
        #     if [ $ret == 0 ]; then
        #         nohup ~/quicktile/quicktile.sh --daemonize >/dev/null 2>&1 &
        #     fi
        # fi

        export PATH=/home/mei/.local/bin:$PATH

        toggle_suspend(){
            is_masked=$(systemctl is-enabled sleep.target)

            # 状態に応じてコマンドをトグル
            if [ "$is_masked" = "masked" ]; then
                sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
                echo "Suspend is now enabled."
            else
                sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
                echo "Suspend is now disabled."
            fi
        }
        ;;
esac

#==========#
