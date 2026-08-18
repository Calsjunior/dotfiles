{
  imports = [
    ./hardware-configuration.nix
    ../shared/configuration.nix
  ];

  # Temporarily prevent the "-6" error spam on wake from hibernation caused by
  # the DDR5 temperature sensors.
  boot.blacklistedKernelModules = [ "spd5118" ];
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

  sys = {
    hardware = {
      nvidia = {
        enable = true;
        prime = {
          enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      power = {
        enable = true;
        batteryMaxFreq = 2000000;
        chargerMaxFreq = 2600000;
      };
    };
  };
}
