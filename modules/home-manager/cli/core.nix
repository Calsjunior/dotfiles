{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    cli.core.enable = lib.mkEnableOption "Enable core CLI utilities";
  };

  config = lib.mkIf config.cli.core.enable {

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    home.packages = with pkgs; [
      fzf
      fd
      ripgrep
      eza
    ];
  };
}
