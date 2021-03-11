#to process .bashrc                                                                                                                                           
if [ -f ~/dotfiles/.bashrc ];then
    . ~/dotfiles/.bashrc
fi
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"

eval "$(rbenv init -)"

export PATH="$HOME/.cargo/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init -)"
