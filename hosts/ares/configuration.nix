{
  config,
  ...
}:
{
  imports = [
    ../shared/configuration.nix
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 3;
    };
  };

  sops.secrets.wg_private_key_ares = { };

  sys = {
    hardware = {
      nvidia = {
        enable32Bit = true;
        enable = true;
        prime = {
          enable = false;
        };
      };
    };
    network = {
      enable = true;
      warp = {
        enable = true;
        gateways = [ "192.168.0.1" ];
        privateKeyFile = config.sops.secrets.wg_private_key_ares.path;
        reserved = [
          107
          43
          226
        ];
      };
    };
    swap = {
      enable = true;
      sizeMiB = 8 * 1024;
    };
    gaming.enable = true;
  };
}
