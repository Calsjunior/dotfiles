{ config, lib, ... }:
{
  options.sys.appimage.enable = lib.mkEnableOption "appImage support";

  config = lib.mkIf config.sys.appimage.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
