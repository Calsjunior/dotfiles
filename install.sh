#!/usr/bin/env bash

# Hypr, caelestia will be always installed
declare -A packages=(
    # [Folder] = "Command:Package"
    [fastfetch]="fastfetch:fastfetch"
    [kitty]="kitty:kitty"
    [nvim]="nvim:nvim"
    [starship]="starship:starship"
    [yazi]="yazi:yazi"
    [zathura]="zathura:zathura"
    [zshrc]="zsh:zsh"
)

declare -A install_packages=(
    [hypr]="hyprland:hyprland"
    [caelestia]="caelestia:caelestia-shell-git"
    [schemes]="none"
)

packages_selected=false
aur_helper=""

dotfiles="$(dirname "$(realpath "$0")")"
config="$HOME/.config"
caelestia_schemes="/usr/lib/python3.13/site-packages/caelestia/data/schemes"

# Colors
blue='\033[0;34m'
green='\033[0;32m'
red='\033[0;31m'
default='\033[0m'

log() {
    echo -e "${blue} $1 ${default}"
}
success() {
    echo -e "${green} $1 ${default}"
}
warn() {
    echo -e "${red} $1 ${default}"
}

get_package_info() {
    local value=$1

    # Get Command:Package
    command_value="${value%%:*}"
    package_value="${value##*:}"
}

print_help() {
    echo " Usage: ./install.sh [-h] [--options]"
    echo " options:"
    printf "%-30s %s\n" " -h, --help" "show this help message and exit"
    printf "%-30s %s\n" " --aur-helper=[yay|paru]" "the AUR helper to use"
    local folder
    for folder in "${!packages[@]}"; do
        get_package_info "${packages["$folder"]}"
        printf "%-30s %s\n" " --$folder" "install $package_value config"
    done
}

backup() {
    if [[ ! -d "$config.bak" ]]; then
        cp -r $config $config.bak
        return
    fi

    warn "Backup already exists. Do you want to overwrite? [Y/N]"
    read -sn 1 choice

    if [[ "$choice" =~ [yY] ]]; then
        rm -rf $config.bak
        cp -r $config $config.bak
        return
    fi

    # Skip if any other input
    echo ""
    success "Skipping..."
}

check_dependencies() {
    log "Checking dependencies..."

    # Check if user input aur_helper
    if [[ -n "$aur_helper" ]]; then
        if ! command -v "$aur_helper" &>/dev/null; then
            warn "$aur_helper is not installed. Please install $aur_helper to proceed."
            return
        fi
    fi

    # Check if yay and paru installed on system if user did not input
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warn "AUR helper is not installed. Please install an AUR helper like yay or paru to proceed."
        return
    fi

    # Check if selected packages are installed
    local missing_package=()
    local folder
    for folder in "${!install_packages[@]}"; do
        get_package_info "${install_packages["$folder"]}"

        if [[ "$command_value" == "none" || -z "$command_value" ]]; then
            continue
        fi

        if ! command -v "$command_value" &>/dev/null; then
            missing_package+=("$package_value")
        fi
    done

    if [[ -n "$missing_package" ]]; then
        warn "Missing packages: ${missing_package[@]}. Installing now..."
        "$aur_helper" -S "${missing_package[@]}"
        return
    fi

    success "All dependencies satistied."
    echo ""
}

install_schemes() {
    log "Installing custom caelestia themes..."

    local schemes_dir="$dotfiles/schemes"
    if [[ ! -d "$schemes_dir" ]]; then
        warn "Schemes folder missing in dotfiles. Schemes won't be installed."
        return
    fi

    if [[ ! -d "$caelestia_schemes" ]]; then
        warn "Caelestia schemes directory not found. Is caelestia-shell installed?"
        return
    fi

    for theme_path in "$schemes_dir"/*; do
        if [[ ! -d "$theme_path" ]]; then
            continue
        fi

        local theme_name=$(basename "$theme_path")
        local source_file="$theme_path/hard/dark.txt"
        local target_dir="$caelestia_schemes/$theme_name/hard"

        if [[ ! -f "$source_file" ]]; then
            warn "Missing scheme file. Source file need to be at $source_file."
        fi

        sudo mkdir -p "$target_dir"
        success "Linking scheme: $theme_name..."
        sudo ln -sf "$source_file" "$target_dir/dark.txt"
    done

    success "Done linking themes."
    echo ""
}

run_stow() {
    if [[ -v install_packages["schemes"] ]]; then
        install_schemes
    fi

    log "Stowing packages..."
    local folder
    for folder in "${!install_packages[@]}"; do
        if [[ ! -d "$dotfiles/$folder" ]]; then
            warn "$folder doesn't exists. Skipping..."
            continue
        fi
        success "Stowing $folder..."
        stow -t "$HOME" "$folder"
    done

}

# Start
for args in "$@"; do
    case "$args" in
        "-h" | "--help")
            print_help
            exit 0
            ;;
        "--aur-helper="*)
            aur_helper="${args#--aur-helper=}"
            if [[ "$aur_helper" != "yay" && "$aur_helper" != "paru" ]]; then
                warn "--aur-helper must be yay or paru"
                exit 0
            fi
            ;;
        "--"*)
            input_folder="${args#--}"
            if [[ "${packages[*]}" != *"$input_folder"* ]]; then
                warn "Unknown option: $args"
                exit 1
            fi

            # Check for duplicate packages
            if [[ -z "${install_packages[$input_folder]}" ]]; then
                install_packages["$input_folder"]="${packages["$input_folder"]}"
                packages_selected=true
            fi
            ;;
    esac
done

if ! "$packages_selected"; then
    for folder in "${!packages[@]}"; do
        install_packages["$folder"]="${packages["$folder"]}"
    done
fi

echo ""
echo "    ▄████████     ███        ▄█    █▄       ▄████████ ███▄▄▄▄      ▄████████ "
echo "   ███    ███ ▀█████████▄   ███    ███     ███    ███ ███▀▀▀██▄   ███    ███ "
echo "   ███    ███    ▀███▀▀██   ███    ███     ███    █▀  ███   ███   ███    ███ "
echo "   ███    ███     ███   ▀  ▄███▄▄▄▄███▄▄  ▄███▄▄▄     ███   ███   ███    ███ "
echo " ▀███████████     ███     ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ███   ███ ▀███████████ "
echo "   ███    ███     ███       ███    ███     ███    █▄  ███   ███   ███    ███ "
echo "   ███    ███     ███       ███    ███     ███    ███ ███   ███   ███    ███ "
echo "   ███    █▀     ▄████▀     ███    █▀      ██████████  ▀█   █▀    ███    █▀  "
echo ""
log "Welcome to athena dotfiles installer!"
log "Before we start, would you like to backup your config directory?"
echo ""
log "[1] Yes, please!    [2] Nope, I already did."
echo ""
read -sn 1 choice

if [[ ! "$choice" =~ [1-2] ]]; then
    log "Exiting..."
    exit 0
fi

if [ "$choice" == 1 ]; then
    backup
else
    success "Skipping backup..."
fi

check_dependencies
run_stow

echo ""
success "Done! Enjoy the setup!"
