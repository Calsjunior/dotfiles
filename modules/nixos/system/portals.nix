{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    sys.portals.xdg-desktop-portal.enable = lib.mkEnableOption "Enable capabilities fix for termfilechooser";
  };

  config = lib.mkIf config.sys.portals.xdg-desktop-portal.enable {
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
  };
}
