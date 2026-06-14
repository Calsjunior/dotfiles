{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.sys.fonts = {
    enable = lib.mkEnableOption "Enable custom system fonts";

    defaultSansSerif = lib.mkOption {
      type = lib.types.str;
      default = "Inter";
      description = "Default system-wide sans-serif font.";
    };

    defaultMonospace = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font Mono";
      description = "Default system-wide monospace font.";
    };
  };

  config = lib.mkIf config.sys.fonts.enable {
    fonts.packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ config.sys.fonts.defaultSansSerif ];
      monospace = [ config.sys.fonts.defaultMonospace ];
    };

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
