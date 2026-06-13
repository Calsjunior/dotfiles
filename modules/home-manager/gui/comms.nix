{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gui.comms.enable = lib.mkEnableOption "Enable Communication Apps";
  };

  config = lib.mkIf config.gui.comms.enable {

    home.packages = with pkgs; [
      telegram-desktop
      vesktop
    ];

  };
}
