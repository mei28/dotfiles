#to process .bashrc                                                                                                                                           
if [ -f ~/dotfiles/.bashrc ];then
    . ~/dotfiles/.bashrc
fi
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
eval "$(rbenv init -)"
