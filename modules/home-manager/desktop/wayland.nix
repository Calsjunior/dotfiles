{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    desktop.wayland.enable = lib.mkEnableOption "Enable Wayland clipboard and CLI tools";
  };

  config = lib.mkIf config.desktop.wayland.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    home.shellAliases = {
      c = "wl-copy";
    };
  };
}
