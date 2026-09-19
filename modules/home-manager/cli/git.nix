{
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
        init.defaultBranch = "main";
        core.editor = config.home.sessionVariables.EDITOR or "vim";
        pull.rebase = true;
        push.autoSetupRemote = true;
        branch.sort = "-committerdate";
        checkout.defaultRemote = "origin";
        fetch.prune = true;
        rerere.enabled = true;
      };
      ignores = [
        ".direnv"
      ];
    };

    programs.gh.enable = true;
  };
}
