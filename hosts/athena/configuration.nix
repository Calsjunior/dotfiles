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
    efi.efiSysMountPoint = "/boot";
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 5;
    };
  };

  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  time.timeZone = "Asia/Phnom_Penh";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
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
        enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    hardware.power.enable = true;
    dm.ly.enable = true;
    fonts.enable = true;
    core.enable = true;
    shell.zsh.enable = true;
  };

  wm.hyprland.enable = true;

}
