DOT_FILES=(.bashrc  .bash_profile  .config  .git-prompt.sh)

for file in ${DOT_FILES[@]}
do 
    ln -sfv $HOME/dotfiles/$file $HOME/$file
    echo $file
done

# 初回git-promptの認識
source .git-prompt.sh
