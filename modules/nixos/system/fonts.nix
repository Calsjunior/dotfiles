{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    sys.fonts.enable = lib.mkEnableOption "Enable custom system fonts";
  };

  config = lib.mkIf config.sys.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
