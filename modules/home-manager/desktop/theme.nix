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
    home.pointerCursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
    };
  };
}
