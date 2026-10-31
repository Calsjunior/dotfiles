{
  config,
  lib,
  ...
}:
let
  cfg = config.cli.git;
in
{
  options.cli.git = {
    enable = lib.mkEnableOption "Enable Git and GitHub CLI";

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "John Doe";
        description = "The name for Git commits.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        example = "johndoe@gmail.com";
        description = "The email for Git commits.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.user.name;
          email = cfg.user.email;
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
