{
  config,
  lib,
  user,
  ...
}:
{
  options.sys.secrets.enable = lib.mkEnableOption "Enable Sops-Nix Secret Management";

  config = lib.mkIf config.sys.secrets.enable {
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
      secrets = {
        "github_token" = { };
        "github_ssh_key" = {
          owner = "${user}";
          mode = "0600";
        };
      };
    };
  };
}
