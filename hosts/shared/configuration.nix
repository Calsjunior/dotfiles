{
  user,
  hostname,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  time.timeZone = "Asia/Phnom_Penh";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  sys = {
    hardware.intel.enable = true;
    dm.ly.enable = true;
    core.enable = true;
    shell.zsh.enable = true;
    secrets.enable = true;
    fonts = {
      enable = true;
      defaultMonospace = "Lilex Nerd Font";
    };
    portals.xdg-desktop-portal = {
      enable = true;
      termfilechooser.enable = true;
    };
  };

  wm.hyprland.enable = true;
}
