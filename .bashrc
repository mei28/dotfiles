# .bashrc

# set alias

# ls(color)

alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'

# prompt

source ~/.git-prompt.sh
PS1='\[\e[34m\]\w \[\e[32m$(__git_ps1 "(%s)")\]\[\e[37m\]\$\[\e[0m\] '

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/bin/git:$PATH"
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
