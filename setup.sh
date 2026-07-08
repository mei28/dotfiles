#!/bin/bash

# .claude は home-manager (profiles/base.nix) が mkOutOfStoreSymlink で管理する
DOT_FILES=(.config .rye)

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

