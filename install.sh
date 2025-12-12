#!/usr/bin/env bash

# Hypr, caelestia, and gtks config will be always installed
no_confirm=false
install_fastfetch=false
install_kitty=false
install_nvim=false
install_starship=false
install_yazi=false
install_zathura=false
install_fastfetch=false
aur_helper=""

config="$HOME/.config"

# Colors
blue='\033[0;34m'
green='\033[0;32m'
red='\033[0;31m'

log() {
    echo -e "${blue} $1"
}
success() {
    echo -e "${green} $1"
}
warn() {
    echo -e "${red} $1"
}

print_help() {
    echo "Usage: ./install.sh [-h] [--options]"
    echo
    echo "options:"
    echo "  -h, --help                 show this help message and exit"
    echo "  --noconfirm                do not confirm package installation"
    echo "  --fastfetch                install fastfetch config"
    echo "  --kitty                    install kitty config"
    echo "  --nvim                     install nvim config"
    echo "  --starship                 install starship config"
    echo "  --yazi                     install yazi config"
    echo "  --zathura                  install zathura config"
    echo "  --zshrc                    install zathura config"
    echo "  --aur-helper=[yay|paru]    the AUR helper to use"
    exit 0
}

backup() {
    if [[ ! -d "$config.bak" ]]; then
        cp -r $config $config.bak
        return
    fi

    warn "Backup already exists. Do you want to overwrite? [Y/N]"
    read -sn 1 choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
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
    if [[ ! -z "$aur_helper" ]]; then
        if ! command -v "$aur_helper" &>/dev/null; then
            warn "$aur_helper is not installed. Please install $aur_helper to proceed."
            return
        fi
    fi

    # Check if yay and paru installed on system if user did not input
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        warn "AUR helper is not installed. Please install an AUR helper like yay or paru to proceed."
        return
    fi
}

# Start
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h | --help) print_help ;;
        --noconfirm)
            no_confirm=true
            shift
            ;;
        --fastfetch)
            install_fastfetch=true
            shift
            ;;
        --kitty)
            install_kitty=true
            shift
            ;;
        --nvim)
            install_nvim=true
            shift
            ;;
        --starship)
            install_starship=true
            shift
            ;;
        --yazi)
            install_yazi=true
            shift
            ;;
        --zathura)
            install_zathura=true
            shift
            ;;
        --zshrc)
            install_fastfetch=true
            shift
            ;;
        --aur-helper=*)
            helper="${1#*=}"
            if [[ "$helper" != "yay" && "$helper" != "paru" ]]; then
                echo "Error: --aur-helper must be 'yay' or 'paru'"
                exit 1
            fi
            aur_helper="$helper"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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
if [[ "$no_confirm" = "true" ]]; then
    backup
    check_dependencies
    exit 1
fi

log "Before we start, would you like to backup your config directory?"
echo ""
log "[1] Yes, please!    [2] Nope, I already did."
echo ""
read -sn 1 choice

if [[ ! "$choice" =~ [1-2] ]]; then
    log "Exiting..."
    exit 1
fi

if [ "$choice" == 1 ]; then
    backup
else
    success "Skipping backup..."
fi

check_dependencies
