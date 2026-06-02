{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    cli.git.enable = lib.mkEnableOption "Enable Git and GitHub CLI";
  };

  config = lib.mkIf config.cli.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "cal";
          email = "sakphea05@gmail.com";
        };
        init = {
          defaultBranch = "main";
        };
        core = {
          editor = "nvim";
        };
      };
    };

    programs.gh.enable = true;
  };
}
