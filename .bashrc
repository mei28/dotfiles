# .bashrc
#========#
# COMMON #
#========#

# prompt

source ~/.git-prompt.sh
PS1='\[\e[34m\]\w \[\e[0;32m\]$(__git_ps1 "(%s)")\[\e[0;37m\]\$\[\e[0m\] '
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/bin/git:$PATH"

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# mkdir and change directory
mkcd(){
  mkdir -p $1 && cd $1 && pwd
}


# ruby env
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# rust env
export PATH="$HOME/.cargo/bin:$PATH"

# pyenv env

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
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
export PATH="/usr/local/opt/llvm/bin:$PATH"


## activate virtualenv
if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
  source "${VIRTUAL_ENV}/bin/activate"  
fi


## activate_virtual env
actvenv(){
  if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
    source "${VIRTUAL_ENV}/bin/activate"  # commented out by conda initialize
    echo "activate ${VIRTUAL_ENV}!!"
  fi
}

# actenv
actenv(){
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
  echo "activate pyenv!!"
  if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
    source "${VIRTUAL_ENV}/bin/activate"  # commented out by conda initialize
    echo "activate ${VIRTUAL_ENV}!!"
  fi
}



## rm alias
if type trash-put &> /dev/null
then
    alias rm=trash-put
fi

# deno
export DENO_INSTALL="/home/mei/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"


# pytest
alias pt='pytest'


# compile c++
cgpp(){
  g++ -std=gnu++17 -Wall -Wextra -O2 -o ./a.out $1 && ./a.out
} 

# cd..
alias cd..="cd .."

# shutdown
alias shutdownnow="sudo shutdown -h now"

# restart
alias restartnow="sudo shutdown -r now"

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
    ## google key
    export GOOGLE_APPLICATION_CREDENTIALS="/Users/mei/gcloud/exmt-app-622421091860.json"
    
    hideDesktopIcon(){
      defaults write com.apple.finder CreateDesktop -boolean false && killall Finder
    }
     showDesktopIcon() {
       defaults write com.apple.finder CreateDesktop -boolean true && killall Finder
     }
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
    source /usr/share/bash-completion/bash_completion

    # pbcopy for linux
    pbc(){
      cat $1 | xsel --clipboard --input && echo "Copied $1!!"
    }

    ## google key
   export GOOGLE_APPLICATION_CREDENTIALS="/home/mei/gcloud/exmt-app-622421091860.json"

    # cuda
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

    # suspend
    alias suspend='systemctl suspend'

    # powertop auto tune
    alias powtune='sudo powertop --auto-tune'
    alias powtop='sudo powertop'
    ;;
esac

#==========#




