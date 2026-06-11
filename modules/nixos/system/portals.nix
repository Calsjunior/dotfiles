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
    # Hacky fix to get xdg-desktop-portal-termfilechooser to work on QT
    # applications like Telegram. Will be removed once a proper fix is found.
    security.wrappers.xdg-desktop-portal = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_ptrace+eip";
      source = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
    };

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

    systemd.user.services.xdg-desktop-portal = {
      serviceConfig = {
        ExecStart = [
          ""
          "/run/wrappers/bin/xdg-desktop-portal"
        ];
      };
    };
  };
}
