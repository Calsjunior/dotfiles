{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}:
{
  options.sys.core.enable = lib.mkEnableOption "Enable core system utilities";

  config = lib.mkIf config.sys.core.enable {
    documentation = {
      dev.enable = true;
      man.cache.enable = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "${dotfilesPath}";
    };

    environment.systemPackages = with pkgs; [
      git
      man-pages
      man-pages-posix
    ];
  };
}
