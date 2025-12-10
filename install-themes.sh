#!/bin/bash

# The destination where Caelestia looks for themes
DEST="/usr/lib/python3.13/site-packages/caelestia/data/schemes"

# Ensure we are in the right directory
REPO_DIR=$(dirname "$(realpath "$0")")/colorschemes

echo "Linking themes from $REPO_DIR to $DEST..."

# Loop through your custom themes
for theme in gruvbox everforest nord; do
    echo "Installing $theme..."

    # 1. Create the folder in the system (requires sudo)
    sudo mkdir -p "$DEST/$theme/hard"

    # 2. Link the dark.txt file
    # We use 'ln -sf' to force the link (overwrite if exists)
    sudo ln -sf "$REPO_DIR/$theme/hard/dark.txt" "$DEST/$theme/hard/dark.txt"
done

echo "Done! You can now run 'caelestia scheme set -n gruvbox -f default'"
