{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    sys.shell.zsh.enable = lib.mkEnableOption "Enable Zsh as default system shell";
  };

  config = lib.mkIf config.sys.shell.zsh.enable {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
  };
}
