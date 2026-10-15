{
  config,
  lib,
  osConfig,
  ...
}:
{
  options = {
    cli.ssh.enable = lib.mkEnableOption "Enable SSH";
  };

  config = lib.mkIf config.cli.ssh.enable {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "yes";
        };

        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = osConfig.sops.secrets.github_ssh_key.path;
        };
      };
    };
  };
}
