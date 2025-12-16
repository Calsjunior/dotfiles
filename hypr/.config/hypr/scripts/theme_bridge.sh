#!/usr/bin/env bash

state_file="$HOME/.local/state/caelestia/scheme.json"
nvim_theme_file="$HOME/.config/nvim/lua/config/current_theme.lua"

declare -A theme_templates=(
    ["everforest"]="require('everforest').setup({ background = '%s' }); vim.cmd.colorscheme('everforest')"
    ["gruvbox-material"]="require('gruvbox-material').setup({ contrast = '%s' }); vim.cmd.colorscheme('gruvbox-material')"
)

update_term() {
    content=$(cat "$state_file")

    # grep for "item": "item"
    name=$(echo "$content" | grep -oP '"name":\s*"\K[^"]+')
    mode=$(echo "$content" | grep -oP '"mode":\s*"\K[^"]+')
    flavour=$(echo "$content" | grep -oP '"flavour":\s*"\K[^"]+')

    # Kitty
    # Replace all dashes with spaces
    clean_name="${name//-/ }"
    if [[ "$flavour" == "default" || -z "$flavour" ]]; then
        theme="$clean_name $mode"
    else
        theme="$clean_name $mode $flavour"
    fi
    kitten themes --reload-in=all "$theme"

    # Neovim
    local template="${theme_templates[$name]}"
    local lua_cmd=""
    if [[ -n "$template" ]]; then
        local specific_cmd=$(printf "$template" "$flavour")
        lua_cmd="$lua_cmd $specific_cmd"
    else
        lua_cmd="$lua_cmd vim.cmd.colorscheme('$name')"
    fi

    mkdir -p "$(dirname "$nvim_theme_file")"
    echo "$lua_cmd" >"$nvim_theme_file"

    # Send Live Update
    for server in /run/user/$(id -u)/nvim.*; do
        if [[ -S "$server" ]]; then
            nvim --server "$server" --remote-expr "execute('lua dofile(\"$nvim_theme_file\")')" &>/dev/null &
        fi
    done
}

update_term

while inotifywait -e close_write,moved_to,create -q "$state_file"; do
    update_term
done
