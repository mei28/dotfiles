DOT_FILES=(.config .rye)

for file in ${DOT_FILES[@]}
do 
    ln -snfv $HOME/dotfiles/$file $HOME/$file
    echo $file
done

