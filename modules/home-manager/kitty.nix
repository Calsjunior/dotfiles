{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    terminal.kitty.enable = lib.mkEnableOption "Enable Kitty";
  };

  config = lib.mkIf config.terminal.kitty.enable {
    home.packages = [ pkgs.kitty ];
    xdg.configFile."kitty".source = ../../config/kitty;
  };
}
