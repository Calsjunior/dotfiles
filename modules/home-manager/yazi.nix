{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    cli.yazi.enable = lib.mkEnableOption "Enable Yazi";
  };

  config = lib.mkIf config.cli.git.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
