{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.sys.portals.xdg-desktop-portal = {
    enable = lib.mkEnableOption "Enable basic Wayland portals";
    termfilechooser.enable = lib.mkEnableOption "Route FileChooser through terminal backend";
  };

  config = lib.mkIf config.sys.portals.xdg-desktop-portal.enable {
    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ]
      ++ lib.optional config.sys.portals.xdg-desktop-portal.termfilechooser.enable pkgs.xdg-desktop-portal-termfilechooser;

      config = {
        common = {
          default = [ "gtk" ];
        }
        // lib.optionalAttrs config.sys.portals.xdg-desktop-portal.termfilechooser.enable {
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    };
  };
}
