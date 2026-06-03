{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  options.sys.core.enable = lib.mkEnableOption "Enable core system utilities";

  config = lib.mkIf config.sys.core.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${user}/dotfiles"; # Hardcode dotfiles location
    };

    environment.systemPackages = with pkgs; [
      git
    ];
  };
}
