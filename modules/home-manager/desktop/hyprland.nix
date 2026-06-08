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

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-termfilechooser
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    };

    xdg.configFile."hypr".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/hypr";
  };
}
