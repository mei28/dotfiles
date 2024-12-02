DOT_FILES=(.bashrc  .bash_profile  .config  .git-prompt.sh .rye)

for file in ${DOT_FILES[@]}
do 
    ln -snfv $HOME/dotfiles/$file $HOME/$file
    echo $file
done

