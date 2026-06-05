{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sys.hardware.nvidia;
in
{
  options.sys.hardware.nvidia = {
    enable = lib.mkEnableOption "Enable Nvidia Drivers";

    prime = {
      enable = lib.mkEnableOption "Enable PRIME Hybrid Offload";
      intelBusId = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;
    hardware.nvidia = {
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      powerManagement.finegrained = cfg.prime.enable;

      prime = lib.mkIf cfg.prime.enable {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
      };
    };
  };
}
