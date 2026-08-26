{
  config,
  lib,
  osConfig,
  dotfilesPath,
  pkgs,
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

    desktop = {
      hasCompositor = true;
      noctalia.extraPaths = [ pkgs.socat ];
    };

    home.packages = with pkgs; [
      hyprpicker
    ];

    xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr";
  };
}
