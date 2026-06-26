# Modular NixOS Configuration

> [!NOTE]
> If you are here for the eye-candy arch configuration, then
> checkout the other branch.

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

   > [!IMPORTANT]
   > Be sure to replace the hardware-configuration.nix with your own file.

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
