{ config, lib, ... }:
{
  options.sys.printing.enable = lib.mkEnableOption "Enable printing service";

  config = lib.mkIf config.sys.printing.enable {
    services.ipp-usb.enable = true;
  };
}
