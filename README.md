# athena-dotfiles

A highly configured and automated dotfiles setup for Arch Linux, featuring **Hyprland**, **Caelestia Shell**, and a custom live theme synchronization system.

![Demo](assets/showcase.gif)

<!-- TOC -->

## Table of Contents

- [Features](#features)
- [System Philosophy](#system-philosophy)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Themes and Schemes](#themes-and-schemes)

<!-- /TOC -->

## Features

- **Hyprland**: Tiling window manager configuration
- **Caelestia Shell**: The beauty of this dotfiles
- **Live Theming**: Changing themes instantly updates Kitty, Neovim, and your wallpapers
- **System Integration**: Custom scripts for wallpaper picking and your favorite custom schemes for caelestia shell
- **Modular Installer**: A script to install only what you want from this configuration

## System Philosophy

This setup is designed for Keyboard-driven development.
- **Window Management**: Hyprland handles all titling. No floating windows
  except for termfilechooser (replaces GTK/QT application default file
  picker with yazi).
- **Terminal as an IDE**: I use kitty as the core application to handle
  terminal multiplexing combined with Hyprland itself.
- **Workspace**: I have all my development environment setup in `~/dev`.
  All dotfiles and scripts are managed via GNU Stow through this repo.

## Requirements

- **OS**: Arch Linux
- **AUR Helper**: `yay` or `paru`
- **Dependencies**: `stow`, `wtype`, `gammastep`, `inotify-tools` (other dependencies depends on configs you want to install)

## Installation

> [!NOTE]
> **About the `install.sh` script**:
> This environment is constantly evolving. While the installer script is
> fully functionally for the core setup, if you or my future self wants to
> use this dotfile, I do not actively update it with every new package or
> tweak I make.
>
> For a complete, up-to-date list of the current system dependencies, check
> `packages.txt` file in the root directory (`dotfiles`).
> For specific component configuration details, please check individual
> `README.md` inside each directory (e.g., `nvim`, `yazi`).

1. Clone the repository:
    ```bash
    git clone https://github.com/Calsjunior/dotfiles.git ~/athena-dotfiles
    cd ~/athena-dotfiles
    ```

2. Run the installer:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3. Follow the prompts: the script will ask for you to backup your existing configs and check for dependencies

## Usage

The installer is modular, meaning you can pick and choose specific components.

| Flag         | Description                                   |
| ------------ | --------------------------------------------- |
| --aur-helper | specify aur helper you want to use (yay/paru) |
| --schemes    | install/update caelestia schemes              |
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

## Themes and Schemes

This setup includes a custom theme bridge script that synchronizes your system in **real-time**.

### How it works

1. Open Caelestia launcher and type `>scheme` or `SUPER CTRL W` if you use my hypr config, and pick a theme (e.g., "everforest").
2. The bridge script detects the change and:
    - Updates **kitty** colors.
    - Updates **neovim** colors via RPC.
    - Sets a random wallpaper from `~/Pictures/Wallpapers/everforest/`.

**To update your themes without reinstalling everything:**

1. Pull the latest changes:
    ```bash
    cd ~/dotfiles
    git pull
    ```

2. Run the installer with the schemes flag:
    ```bash
    ./install.sh --schemes
    ```

This will instantly relink the latest theme files into your system directories at `/usr/lib/python3.13/site-packages/caelestia/data/schemes` so caelestia can see them.

**Custom Wallpapers**: To use the wallpaper sync, organize your wallpapers in `~/Pictures/Wallpapers` like this:

```bash
~/Pictures/Wallpapers/
├── everforest/
│   ├── image1.jpg
│   └── image2.png
├── gruvbox/
└── default/
```

> [!NOTE]
> The theme-bridge.sh script runs automatically via Hyprland (exec-once). It checks for installed apps, so if you don't use Kitty or Neovim, it will simply skip them, and just sync your wallpapers to themes and vice versa!

# Credits

- Window Manager: [Hyprland](https://github.com/hyprwm/Hyprland)
- Shell: [Caelestia-Shell](https://github.com/caelestia-dots/shell)
- Wallpapers are not mine and are credited to their original owners.
