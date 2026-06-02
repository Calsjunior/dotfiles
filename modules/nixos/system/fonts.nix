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
      noto-fonts
      noto-fonts-color-emoji
    ];

    # Font rendering
    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        autohint = false;
        style = "full";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };
}
