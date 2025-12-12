#!/usr/bin/env bash

# Hypr, caelestia will be always installed
no_confirm=false
always_install=("hypr" "caelestia")
packages=("fastfetch" "kitty" "nvim" "starship" "yazi" "zathura" "zshrc")
install_packages=()
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
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warn "AUR helper is not installed. Please install an AUR helper like yay or paru to proceed."
        return
    fi

    # Check if selected packages are installed
    missing_package=()
    for package in "${install_packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            missing_package+=("$package")
        fi
    done

    if [[ ! -z "$missing_package" ]]; then
        log "Missing packages: ${missing_package[@]}. Installing now..."
        "$aur_helper" -S "${missing_package[@]}"
    fi
}

# Start
for args in "$@"; do
    case "$args" in
        "-h" | "--help")
            print_help
            exit 0
            ;;
        "--noconfirm")
            no_confirm=true
            ;;
        "--aur-helper="*)
            aur_helper="${args#--aur-helper=}"
            if [[ "$aur_helper" != "yay" && "$aur_helper" != "paru" ]]; then
                warn "--aur-helper must be yay or paru"
                exit 0
            fi
            ;;
        "--"*)
            input_package="${args#--}"
            if [[ "${packages[*]}" != *"$input_package"* ]]; then
                warn "Unknown option: $args"
                exit 1
            fi

            # Check for duplicate packages
            if [[ "${install_packages[*]}" != *"$input_package"* ]]; then
                install_packages+=("$input_package")
            fi
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
if "$no_confirm"; then
    backup
    check_dependencies
    exit 0
fi

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
