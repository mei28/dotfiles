#!/bin/bash

DOT_FILES=(.config .rye .claude)

for file in "${DOT_FILES[@]}"; do
    TARGET="$HOME/$file"
    SOURCE="$HOME/dotfiles/$file"

    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        echo "Skipping $file: already exists"
    else
        ln -snv "$SOURCE" "$TARGET"
        echo "Linked $file"
    fi
done

