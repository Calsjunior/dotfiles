# Modular NixOS Configuration

> [!NOTE]
> If you are here for the eye-candy Arch configuration, then
> checkout the [`arch` branch](https://github.com/Calsjunior/dotfiles/tree/arch).

A NixOS configuration where everything is modular, independent, reproducible,
and hassle-free; so you can use this entire environment, across any machine,
with a _single_ command; everything, everywhere, all at once.

## Pattern

This setup relies on the options pattern. Every single app, tool, and system
feature listed in this repo _must_ be explicitly enabled.

## Dependencies

Dependency and package leakage is everyone's worst nightmare; yes, everyone's.
While it's not perfect, everything made here aims to prevent that.

## Usage

I recommend forking, cloning, or doing whatever you want with this repo on your
own machine and using it as a base template. Everyone is different, and my
specific tools or workflow might not be the right fit for you.

1. Clone the repository:

   ```
   git clone https://github.com/Calsjunior/dotfiles.git
   ```

2. Create your host configuration:

   Since everything is opt-in, you build your own configuration by creating your
   host files. The easiest way to start is by copying one of the existing hosts.

   ```
   cp -r hosts/ares hosts/your-hostname
   ```

   Be sure to replace the `hardware-configuration.nix` with your own file.

   Next, open hosts/your-hostname/configuration.nix (for system-level modules) and
   hosts/your-hostname/home.nix (for user-level modules), and toggle what your
   heart desires.

   ```nix
   # hosts/your-hostname/configuration.nix
   {
   # System
   sys.core.enable = true;
   sys.fonts.enable = true;
   sys.hardware.nvidia.enable = true;

   # Window Manager Hooks
   wm.hyprland.enable = true;
   }
   ```

   ```nix
   # hosts/your-hostname/home.nix
   {
     # CLI Tools
     cli.core.enable = true;
     cli.yazi.enable = true;
     cli.neovim.enable = true;

     # GUI & Desktop
     gui.kitty.enable = true;
     gui.browser.zen.enable = true;
     desktop.hyprland.enable = true;
   }
   ```

3. Register your new host:

   Open flake.nix and add your new host configuration under the nixosConfigurations
   output block, pointing it to your newly created directory.

   ```nix
   "your-hostname" =
   let
     hostname = "your-hostname";
   in
   nixpkgs.lib.nixosSystem {
     specialArgs = {
       inherit
         inputs
         user
         hostname
         ;
     };
     modules = [
       ./hosts/${hostname}/configuration.nix
       ./modules/nixos

       home-manager.nixosModules.home-manager
       {
         home-manager = {
           useGlobalPkgs = true;
           useUserPackages = true;
           users.${user} = import ./hosts/${hostname}/home.nix;
           sharedModules = [ ./modules/home-manager ];
           extraSpecialArgs = { inherit inputs user hostname; };
           backupFileExtension = "backup";
         };
       }
     ];
   };
   ```

4. Apply the configuration:
   ```
   git add .
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

## Structure

```
.
├── config
│   ├── formatters
│   │   ├── .clang-format
│   │   └── biome.json
│   ├── hypr
│   │   ├── modules
│   │   ├── scripts
│   │   ├── .luarc.json
│   │   ├── hyprland.lua
│   │   └── noctalia.lua
│   ├── noctalia
│   │   └── config.toml
│   └── nvim
│       ├── after
│       ├── lua
│       ├── .neoconf.json
│       ├── init.lua
│       ├── lazy-lock.json
│       └── lazyvim.json
├── hosts
│   ├── ares
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   └── athena
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── home.nix
├── modules
│   ├── home-manager
│   │   ├── cli
│   │   ├── desktop
│   │   ├── gui
│   │   ├── shell
│   │   └── default.nix
│   └── nixos
│       ├── hardware
│       ├── system
│       ├── wm
│       └── default.nix
├── templates
│   ├── c-cpp
│   │   ├── .envrc
│   │   └── flake.nix
│   └── web
│       ├── .envrc
│       └── flake.nix
```

### Adding your own tools

Sooner or later, you'd want to add your own customization, add your own tools,
programs, or games(?).

If the tools you want to add require `sudo` access, for instance, then put
their files in `./modules/nixos/`. Otherwise, user-level tools should go in
`./modules/home-manager/`

Let's take a look at the `./modules/home-manager/cli/wayland-tools.nix` as an
example of how to wrap your new programs using the options pattern.

```nix
{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    cli.wayland-tools.enable = lib.mkEnableOption "Enable Wayland clipboard and CLI tools";
  };

  config = lib.mkIf config.cli.wayland-tools.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpicker
    ];

    home.shellAliases = {
      c = "wl-copy";
    };
  };
}
```

Now in your `./hosts/your-hostname/home.nix`, you enable this bundle of tools by
simply doing:

```nix
cli.wayland-tools.enable = true;
```

Then run:

```
sudo nixos-rebuild switch --flake .#your-hostname
```

> [!TIP]
> If you enabled the `nh` (nix-helper) tool during your initial setup (`./modules/nixos/system/core.nix`), you can
> use this much cleaner command for all subsequent rebuilds:
> `nh os switch ~/dotfiles -H .#your-hostname`
