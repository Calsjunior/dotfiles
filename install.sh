#!/usr/bin/env bash

# Hypr, caelestia will be always installed
declare -A packages=(
    # [Folder] = "Command:Package Command:Package"
    [fastfetch]="fastfetch:fastfetch"
    [kitty]="kitty:kitty inotifywait:inotify-tools"
    [nvim]="nvim:nvim fd:fd ripgrep:ripgrep"
    [starship]="starship:starship"
    [yazi]="yazi:yazi ripdrag:ripdrag"
    [zathura]="zathura:zathura"
    [zshrc]="zsh:zsh zoxide:zoxide"
    [schemes]="none"
)

declare -A install_packages=(
    [hypr]="hyprland:hyprland stow:stow gammastep:gammastep"
    [caelestia]="caelestia:caelestia-shell-git wtype:wtype"
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
    printf "%-30s %s\n" " --schemes" "install/update schemes"
    local folder
    for folder in "${!packages[@]}"; do
        if [[ "$folder" == "schemes" ]]; then
            continue
        fi
        get_package_info "${packages["$folder"]}"
        printf "%-30s %s\n" " --$folder" "install $package_value config"
    done
}

# TODO: implement a better backup logic instead of backing up the entire .config
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
        local entry="${install_packages["$folder"]}"
        if [[ "$entry" == "none" || -z "$entry" ]]; then
            continue
        fi

        IFS=" " read -r -a depends <<<"$entry"
        for depend in "${depends[@]}"; do
            get_package_info "$depend"

            if ! command -v "$command_value" &>/dev/null; then
                missing_package+=("$package_value")
            fi
        done
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
        for flavour_path in "$theme_path"/*; do
            if [[ ! -d "$flavour_path" ]]; then
                continue
            fi

            local flavour_name=$(basename "$flavour_path")
            for mode_file in "$flavour_path"/*; do
                if [[ ! -f "$mode_file" ]]; then
                    continue
                fi

                local mode_name=$(basename "$mode_file")
                local target_dir="$caelestia_schemes/$theme_name/$flavour_name"
                if [[ ! -d "$target_dir" ]]; then
                    log "Creating scheme: $theme_name/$flavour_name"
                    sudo mkdir -p "$target_dir"
                fi

                sudo mkdir -p "$target_dir"
                log "Linking scheme: $theme_name..."
                sudo ln -sf "$mode_file" "$target_dir/$mode_name"
            done
        done
    done

    success "Done linking themes."
    echo ""
}

run_stow() {
    # Handle schemes
    if [[ -v install_packages["schemes"] ]]; then
        if [[ ! -d "$dotfiles/schemes" ]]; then
            warn "schemes folder missing. Skipping..."
            unset install_packages[schemes]
        else
            install_schemes
            unset install_packages[schemes]
        fi
    fi

    # Handle packages
    local folder
    local to_stow=()
    for folder in "${!install_packages[@]}"; do
        if [[ ! -d "$dotfiles/$folder" ]]; then
            warn "$folder doesn't exists. Skipping..."
            continue
        fi
        to_stow+=("$folder")
    done
    stow -t "$HOME" "${to_stow[@]}"
    log "Stowing packages: ${to_stow[*]}"
    success "Finished stowing packages."
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
            if [[ ! -v packages["$input_folder"] ]]; then
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
    echo ""
fi

check_dependencies
run_stow

echo ""
success "Done! Enjoy the setup!"
