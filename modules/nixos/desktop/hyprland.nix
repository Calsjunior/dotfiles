{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    wm.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.wm.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
