#!/usr/bin/env bash

scheme_state="$HOME/.local/state/caelestia/scheme.json"
wallpaper_state="$HOME/.local/state/caelestia/wallpaper/path.txt"
wallpaper_dir="$HOME/Pictures/Wallpapers"

nvim_locations=(
    "$HOME/.local/share/bob/nvim-bin/nvim"
    "$HOME/.local/bin/nvim"
    "/usr/bin/nvim"
    "/bin/nvim"
)

nvim_cmd=""
for cmd in "${nvim_locations[@]}"; do
    if [[ -x "$cmd" ]]; then
        nvim_cmd="$cmd"
        break
    fi
done

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
    if [[ -n "$nvim_cmd" ]]; then
        local build_type=$("$nvim_cmd" --version | grep -oP 'Build type: \K.*')
        if [[ "$build_type" == "Release" ]]; then
            nvim_theme_file="$HOME/.config/nvim/lua/config/current_theme.lua"
        else
            nvim_theme_file="$HOME/.config/nvim/lua/current_theme.lua"
        fi
    fi

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
            "$nvim_cmd" --server "$server" --remote-expr "execute('lua dofile(\"$nvim_theme_file\")')" &>/dev/null &
        fi
    done
}

sync_from_theme() {
    if [[ ! -f "$scheme_state" ]]; then
        return
    fi
    local content=$(cat "$scheme_state")

    local name=$(echo "$content" | grep -oP '"name":\s*"\K[^"]+')
    local mode=$(echo "$content" | grep -oP '"mode":\s*"\K[^"]+')
    local flavour=$(echo "$content" | grep -oP '"flavour":\s*"\K[^"]+')

    update_wallpaper "$name"

    if command -v kitten &>/dev/null; then
        update_kitty "$name" "$mode" "$flavour"
    fi

    if [[ -n "$nvim_cmd" ]]; then
        update_neovim "$name" "$flavour"
    fi
}

# TODO: add mode and flavour when I make more schemes
sync_from_wallpaper() {
    if [[ ! -f "$wallpaper_state" ]]; then
        return
    fi
    local wallpaper_content=$(cat "$wallpaper_state")
    local current_wallpaper_theme_name=$(basename "$(dirname "$wallpaper_content")")

    if [[ -f "$scheme_state" ]]; then
        local scheme_content=$(cat "$scheme_state")
        local name=$(echo "$scheme_content" | grep -oP '"name":\s*"\K[^"]+')
    fi

    if [[ -n "$current_wallpaper_theme_name" && "$current_wallpaper_theme_name" != "$name" ]]; then
        if [[ "$current_wallpaper_theme_name" != "default" ]]; then
            caelestia scheme set -n "$current_wallpaper_theme_name"
        else
            caelestia scheme set -n "dynamic"
        fi
    fi
}

watch_scheme_dir=$(dirname "$scheme_state")
watch_scheme_file=$(basename "$scheme_state")
watch_wallpaper_dir=$(dirname "$wallpaper_state")
watch_wallpaper_file=$(basename "$wallpaper_state")

# Initiate once when starting
sync_from_theme

inotifywait -m -q -e close_write,moved_to,create "$watch_scheme_dir" "$watch_wallpaper_dir" | while read -r directory events filename; do
    if [[ "$filename" == "$watch_scheme_file" ]]; then
        sync_from_theme
    elif [[ "$filename" == "$watch_wallpaper_file" ]]; then
        sync_from_wallpaper
    fi
done
