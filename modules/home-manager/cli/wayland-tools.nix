{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    cli.wayland-tools.enable = lib.mkEnableOption "Enable Wayland clipboard and CLI tools";
  };

  config = lib.mkIf config.cli.wayland-tools.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpicker
    ];

    home.shellAliases = {
      c = "wl-copy";
    };
  };
}
