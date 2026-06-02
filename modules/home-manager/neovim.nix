{ pkgs, config, lib, ... }:
{
	options = {
		cli.neovim.enable = lib.mkEnableOption "Enable Neovim";
	};

	config = lib.mkIf config.cli.neovim.enable {
		programs.neovim = {
			enable = true;
			defaultEditor = true;
			extraPackages = with pkgs; [
				# Treesitter Build tools
                tree-sitter
				gcc
				gnumake

				# Tools required by LazyVim
				ripgrep
				fd
				fzf
				lazygit

				# Language Servers
				lua-language-server
				nil
			];
		};

		xdg.configFile."nvim".source = ../../config/nvim;
	};
}
