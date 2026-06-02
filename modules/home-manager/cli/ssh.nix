{ config, lib, ... }:
{
  options = {
    cli.ssh.enable = lib.mkEnableOption "Enable SSH";
  };

  config = lib.mkIf config.cli.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}
