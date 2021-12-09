# !/bin/bash

#set up for dein
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
# For example, we just use `~/.cache/dein` as installation directory
sh ./installer.sh ~/.cache/dein
rm ./installer.sh

# deno
# curl -fsSL https://deno.land/x/install/install.sh | sh
brew install deno

