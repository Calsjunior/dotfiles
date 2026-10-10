{
  config,
  ...
}:
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

  sops.secrets.wg_private_key_athena = { };

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
    network = {
      enable = true;
      warp = {
        enable = true;
        gateways = [ "192.168.0.1" ];
        privateKeyFile = config.sops.secrets.wg_private_key_athena.path;
        reserved = [
          250
          250
          224
        ];
      };
    };
    swap.enable = true;
  };
}
