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
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 3;
    };
  };

  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
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
  sys.hardware.nvidia.enable = true;
  sys.dm.ly.enable = true;
  sys.fonts.enable = true;
  sys.core.enable = true;
  sys.shell.zsh.enable = true;
  wm.hyprland.enable = true;

}
