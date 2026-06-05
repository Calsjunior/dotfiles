{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    sys.hardware.nvidia.enable = lib.mkEnableOption "Enable Nvidia Drivers";
  };

  config = lib.mkIf config.sys.hardware.nvidia.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
