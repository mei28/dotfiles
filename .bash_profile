#to process .bashrc                                                                                                                                           
if [ -f ~/dotfiles/.bashrc ]; then
    . ~/dotfiles/.bashrc
fi


# # The next line updates PATH for the Google Cloud SDK.
# if [ -f '~/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '~/Downloads/google-cloud-sdk/path.bash.inc'; fi

# # The next line enables shell command completion for gcloud.
# if [ -f '~/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '~/Downloads/google-cloud-sdk/completion.bash.inc'; fi

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
