{ pkgs, config, lib, ... }:
{
	options = {
		cli.neovim.enable = lib.mkEnableOption "Enable Neovim";
	};

	config = lib.mkIf config.cli.neovim.enable {
		home.packages = [ pkgs.neovim ];
		home.sessionVariables = {
			EDITOR = "nvim";
		};
	};
}
