{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.sys.hardware.intel.enable = lib.mkEnableOption "Enable Intel GPU support";
  config = lib.mkIf config.sys.hardware.intel.enable {
    # https://wiki.nixos.org/wiki/Intel_Graphics
    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    hardware.enableRedistributableFirmware = true;
    boot.kernelParams = [ "i915.enable_guc=3" ];
  };
}
