# .bashrc

# set alias

# ls(color)

alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'

# prompt

source ~/.git-prompt.sh
PS1='\[\e[34m\]\w \[\e[32m$(__git_ps1 "(%s)")\]\[\e[37m\]\$\[\e[0m\] '
