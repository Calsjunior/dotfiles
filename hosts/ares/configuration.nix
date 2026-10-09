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

  sops.secrets.wg_private_key_ares = { };

  sys = {
    hardware = {
      nvidia = {
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
  };
}
