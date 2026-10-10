{ config, lib, ... }:
let
  cfg = config.sys.swap;
in
{
  options.sys.swap = {
    enable = lib.mkEnableOption "swapfile with zswap";
    sizeMiB = lib.mkOption {
      type = lib.types.int;
      default = 4 * 1024;
      description = "Swapfile size in MiB";
    };
  };

  config = lib.mkIf cfg.enable {
    swapDevices = [
      {
        device = "/swapfile";
        size = cfg.sizeMiB;
      }
    ];
    boot.zswap = {
      enable = true;
      compressor = "zstd";
    };
  };
}
