DOT_FILES=(.bashrc  .bash_profile  .config  .git-prompt.sh)

for file in ${DOT_FILES[@]}
do 
    ln -sf $HOME/dotfiles/$file $HOME/$file
    echo $file
done

