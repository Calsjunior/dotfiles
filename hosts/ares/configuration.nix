{
  config,
  lib,
  pkgs,
  user,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use GRUB and OS Prober for Windows Dual Boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      enable = true;
      default = "saved";
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 3;
    };
  };

  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  time.timeZone = "Asia/Phnom_Penh";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  # Modules
  sys = {
    hardware.nvidia = {
      enable = true;
      prime = {
        enable = false;
      };
    };

    hardware.intel.enable = true;

    dm.ly.enable = true;
    core.enable = true;
    shell.zsh.enable = true;

    fonts = {
      enable = true;
      defaultMonospace = "Lilex Nerd Font";
    };

    portals.xdg-desktop-portal = {
      enable = true;
      termfilechooser.enable = true;
    };

    secrets.enable = true;
  };
  wm.hyprland.enable = true;

}
