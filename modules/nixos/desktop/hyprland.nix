# window manager module should always define
# services.displayManager.defaultSession so that other modules can reference
# it.
{ config, lib, ... }:
{
  options.wm.hyprland.enable = lib.mkEnableOption "hyprland window manager";

  config = lib.mkIf config.wm.hyprland.enable {
    programs.hyprland.enable = true;
    services.displayManager.defaultSession = lib.mkDefault "hyprland";
  };
}
