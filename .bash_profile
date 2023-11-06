# Set PATH, MANPATH, etc., for Homebrew.
if [ -e /opt/homebrew/bin/brew ]
then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#to process .bashrc
if [ -f ~/dotfiles/.bashrc ]; then
    . ~/dotfiles/.bashrc
fi

