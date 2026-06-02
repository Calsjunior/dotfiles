{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    wm.hyprland.enable = lib.mkEnableOption "Enable Hyprland Configs";
  };

  config = lib.mkIf config.wm.hyprland.enable {
    xdg.configFile."hypr".source = ../../config/hypr;
  };
}
