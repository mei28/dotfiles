DOT_FILES=(.bashrc  .bash_profile  .config  .git-prompt.sh  .gitconfig  .tmux.conf  .hammerspoon .fzf.bash)

for file in ${DOT_FILES[@]}
do 
    ln -sfv $HOME/dotfiles/$file $HOME/$file
    echo $file
done

# # 初回git-promptの認識
# curl -o $HOME/.git-prompt.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
# curl -o $HOME/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
