{ config, lib, ... }:
{
  options.wm.hyprland.enable = lib.mkEnableOption "hyprland window manager";

  config = lib.mkIf config.wm.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
