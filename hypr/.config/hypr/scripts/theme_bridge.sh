#!/usr/bin/env bash

scheme_state="$HOME/.local/state/caelestia/scheme.json"
wallpaper_state="$HOME/.local/state/caelestia/wallpaper/path.txt"
nvim_theme_file="$HOME/.config/nvim/lua/config/current_theme.lua"
wallpaper_dir="$HOME/Pictures/Wallpapers"

declare -A theme_templates=(
    ["everforest"]="require('everforest').setup({ background = '%s' }); vim.cmd.colorscheme('everforest')"
    ["gruvbox"]="require('gruvbox').setup({ contrast = '%s' }); vim.cmd.colorscheme('gruvbox')"
)

update_wallpaper() {
    local name=$1

    local target_wallpaper_dir="$wallpaper_dir/$name"
    if [[ -f "$wallpaper_state" ]]; then
        local content=$(cat "$wallpaper_state")
        local current_wallpaper_theme_name=$(basename "$(dirname "$content")")
        if [[ "$current_wallpaper_theme_name" == "$name" ]]; then
            return
        fi
    fi

    if [[ ! -d "$target_wallpaper_dir" ]]; then
        target_wallpaper_dir="$wallpaper_dir/default"
    fi
    caelestia wallpaper -r "$target_wallpaper_dir"
}

update_kitty() {
    local name=$1
    local mode=$2
    local flavour=$3

    local clean_name="${name//-/ }"
    if [[ "$flavour" == "default" || -z "$flavour" ]]; then
        local theme="$clean_name $mode"
    else
        local theme="$clean_name $mode $flavour"
    fi

    kitten themes --reload-in=all "$theme"
}

update_neovim() {
    local name=$1
    local contrast=$2

    local template="${theme_templates[$name]}"
    local lua_cmd=""
    if [[ -n "$template" ]]; then
        local specific_cmd=$(printf "$template" "$contrast")
        lua_cmd="$lua_cmd $specific_cmd"
    else
        lua_cmd="$lua_cmd vim.cmd.colorscheme('$name')"
    fi

    mkdir -p "$(dirname "$nvim_theme_file")"
    echo "$lua_cmd" >"$nvim_theme_file"

    # Send Live Update
    local server
    for server in /run/user/$(id -u)/nvim.*; do
        if [[ -S "$server" ]]; then
            nvim --server "$server" --remote-expr "execute('lua dofile(\"$nvim_theme_file\")')" &>/dev/null &
        fi
    done
}

sync_system() {
    local content=$(cat "$scheme_state")

    local name=$(echo "$content" | grep -oP '"name":\s*"\K[^"]+')
    local mode=$(echo "$content" | grep -oP '"mode":\s*"\K[^"]+')
    local flavour=$(echo "$content" | grep -oP '"flavour":\s*"\K[^"]+')

    update_wallpaper "$name"

    if command -v kitten &>/dev/null; then
        update_kitty "$name" "$mode" "$flavour"
    fi

    if command -v nvim &>/dev/null; then
        update_neovim "$name" "$flavour"
    fi
}

sync_system

while inotifywait -e close_write,moved_to,create -q "$scheme_state"; do
    sync_system
done
