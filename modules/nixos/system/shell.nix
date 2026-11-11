{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.sys.shell.zsh.enable = lib.mkEnableOption "zsh as default system shell";

  config = lib.mkIf config.sys.shell.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = false;
    };
    users.defaultUserShell = pkgs.zsh;
  };
}
