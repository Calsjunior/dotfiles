{ config, lib, ... }:
{
  options = {
    sys.dm.ly.enable = lib.mkEnableOption "Enable Ly Display Manager";
  };

  config = lib.mkIf config.sys.dm.ly.enable {
    services.displayManager.ly.enable = true;
  };
}
