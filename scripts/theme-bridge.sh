#!/usr/bin/env bash

state_file="$HOME/.local/state/caelestia/scheme.json"

update_term() {
    content=$(cat "$state_file")

    # grep for "item": "item"
    name=$(echo "$content" | grep -oP '"name":\s*"\K[^"]+')
    mode=$(echo "$content" | grep -oP '"mode":\s*"\K[^"]+')
    flavour=$(echo "$content" | grep -oP '"flavour":\s*"\K[^"]+')

    # Replace all dashes with spaces
    clean_name="${name//-/ }"

    if [[ "$flavour" == "default" || -z "$flavour" ]]; then
        theme="$clean_name $mode"
    else
        theme="$clean_name $mode $flavour"
    fi

    kitten themes --reload-in=all "$theme"
}

update_term

while inotifywait -e close_write,moved_to,create -q "$state_file"; do
    update_term
done
