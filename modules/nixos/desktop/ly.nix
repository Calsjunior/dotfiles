{ config, lib, ... }:
{
  options.sys.dm.ly.enable = lib.mkEnableOption "ly display manager";

  config = lib.mkIf config.sys.dm.ly.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        session_log = null;
      };
    };
  };
}
