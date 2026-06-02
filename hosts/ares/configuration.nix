{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use GRUB and OS Prober for Windows Dual Boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };

  networking.hostName = "ares";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Phnom_Penh";

  users.users.cal = {
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
  wm.hyprland.enable = true;

}
