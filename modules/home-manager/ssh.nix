{ config, lib, ... }:
{
	options = {
		cli.ssh.enable = lib.mkEnableOption "Enable SSH";
	};

	config = lib.mkIf config.cli.ssh.enable {
		programs.ssh = {
			enable = true;
			matchBlocks = {
				"github.com" = {
					hostname = "github.com";
					user = "git";
					identityFile = "~/.ssh/id_ed25519";
				};
			};
		};
	};
}
