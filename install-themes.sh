#!/usr/bin/env bash

DEST="/usr/lib/python3.13/site-packages/caelestia/data/schemes"
REPO_DIR="$(dirname "$(realpath "$0")")/schemes"

echo "Linking themes from $REPO_DIR to $DEST..."

if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Scheme folder not found at $REPO_DIR"
    exit 1
fi

for theme_path in "$REPO_DIR"/*; do
    if [ ! -d "$theme_path" ]; then
        continue
    fi

    theme_name=$(basename "$theme_path")
    echo "Installing theme: $theme_name"

    TARGET_DIR="$DEST/$theme_name/hard"
    SOURCE_FILE="$theme_path/hard/dark.txt"

    if [ ! -f "$SOURCE_FILE" ]; then
        echo "Warning: No dark.txt found in $theme_path/hard/. Skipping."
        continue
    fi

    sudo mkdir -p "$TARGET_DIR"
    sudo ln -sf "$SOURCE_FILE" "$TARGET_DIR/dark.txt"
done

echo "Done! You can now run 'caelestia scheme set -n <theme> -f hard'"
