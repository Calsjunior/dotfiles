{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    desktop.theme.enable = lib.mkEnableOption "Enable desktop theming and cursors";
  };

  config = lib.mkIf config.desktop.theme.enable {
    home.pointerCursor = with pkgs; {
      enable = true;
      name = "Bibata-Modern-Ice";
      package = bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
      GTK_USE_PORTAL = "1";
    };

    gtk = with pkgs; {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = adw-gtk3;
      };
      gtk4.theme = null;
    };
  };
}
