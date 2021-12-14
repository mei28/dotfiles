# .bashrc

# set alias

# ls(color)
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'

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

# pbcopy for macOS

pbc(){
  cat $1 | pbcopy && echo "Copied $1!!"
}

# ruby env
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
eval "$(rbenv init -)"

# rust env
export PATH="$HOME/.cargo/bin:$PATH"

# pyenv env

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"


# clang for nvim, c++
# brew install llvm
export PATH="/usr/local/opt/llvm/bin:$PATH"


## bash completion

## activate virtualenv
if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
  source "${VIRTUAL_ENV}/bin/activate"
fi


## activate_virtual env
actvenv(){
  if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
    source "${VIRTUAL_ENV}/bin/activate"
    echo "activate ${VIRTUAL_ENV}!!"
  fi
}


## google key
export GOOGLE_APPLICATION_CREDENTIALS="/Users/mei/gcloud/exmt-app-622421091860.json"


## rm alias

rm_zip(){
  TIMESTAMP=`date +%Y%m%d_%H%M%S`
  tar zcvf ${TIMESTAMP}".tar.gz" $@
  mv ${TIMESTAMP}".tar.gz" /tmp
  rm $@
}

alias rm='rm_zip'

# deno
export DENO_INSTALL="/home/mei/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# cuda
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
