{ config, lib, ... }:
let
  cfg = config.sys.sudo;
in
{
  options.sys.sudo = {
    enable = lib.mkEnableOption "sudo with a shared credential cache";

    timeout = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Minutes before sudo asks for the password again.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.extraConfig = ''
      Defaults timestamp_type=global
      Defaults timestamp_timeout=${toString cfg.timeout}
    '';
  };
}
