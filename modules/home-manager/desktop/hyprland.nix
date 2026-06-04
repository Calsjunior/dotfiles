{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
{
  options = {
    desktop.hyprland.enable = lib.mkEnableOption "Enable Hyprland Configs";
  };

  config = lib.mkIf config.desktop.hyprland.enable {
    assertions = [
      {
        assertion = osConfig.wm.hyprland.enable;
        message = "Home Manager Hyprland requires system-level Hyprland (wm.hyprland.enable = true).";
      }
    ];

    xdg.configFile."hypr".source = ../../../config/hypr;
  };
}
