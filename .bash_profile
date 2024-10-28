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

#to process .bashrc
if [ -f ~/dotfiles/.bashrc ]; then
    . ~/dotfiles/.bashrc
fi

