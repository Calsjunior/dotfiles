# athena-dotfiles

A highly configured and automated dotfiles setup for Arch Linux, featuring **Hyprland**, **Caelestia Shell**, and a custom live theme synchronization system.

![Demo](assets/showcase.gif)

## Features
- **Hyprland**: Tiling window manager configuration
- **Caelestia Shell**: The beauty of this dotfiles
- **Live Theming**: Changing themes instantly updates Kitty and Neovim
- **Modular Installer**: A script to install only what you want from this configuration
- **System Integration**: Custom scripts for wallpaper picking and your favorite custom schemes for caelestia shell

## Requirements
- **OS**: Arch Linux
- **AUR Helper**: `yay` or `paru`
- **Dependencies**: `stow`, `wtype` (if you use kitty then `inotify-tools` is needed)

## Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/Calsjunior/dotfiles.git ~/athena-dotfiles
    cd ~/athena-dotfiles
    ```

1. Run the installer:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

1. Follow the prompts: the script will ask for you to backup your existing configs and check for dependencies

## Usage
The installer is modular, meaning you can pick and choose specific components.

| Flag         | Description                                  |
| ------------ | --------------------------------------------- |
| --aur-helper | specify aur helper you want to use (yay/paru) |
| --fastfetch  | install fastfetch config                      |
| --kitty      | install kitty config                          |
| --nvim       | install nvim (lazyvim) config                 |
| --starship   | install starship prompt config                |
| --yazi       | install yazi file manager config              |
| --zathura    | install zathura pdf viewer config             |
| --zshrc      | install custom zsh config                     |

Example:
```bash
# Install only Kitty, using Paru
./install.sh --kitty --aur-helper=paru
```

## Theming
The dotfiles contain custom-made themes for caelestia and the installer will run with sudo because caelestia stores their theme at
```bash
/usr/lib/python3.13/site-packages/caelestia/data/schemes
```

## Disclaimer
If you do not want to include kitty or neovim when installing the dotfile, please do the following:
1. Remove `theme_bridge.sh` script from `~/.config/hypr/scripts/theme_bridge.sh`
2. Remove `exec-once = $scripts/theme_bridge.sh` from `~/.config/hypr/hyprland.conf` at line 123

# Credits
- Window Manager: [Hyprland](https://github.com/hyprwm/Hyprland)
- Shell: [Caelestia-Shell](https://github.com/caelestia-dots/shell)
