{
  ...
}:
{
  imports = [
    ../shared/configuration.nix
    ./hardware-configuration.nix
  ];

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

  sys = {
    hardware = {
      nvidia = {
        enable = true;
        prime = {
          enable = false;
        };
      };
    };
  };
}
