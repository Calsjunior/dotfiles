{ config, pkgs, ...}:

{
	home.username = "cal";
	home.homeDirectory = "/home/cal";

	wm.hyprland.enable = true;
	cli.neovim.enable = true;
	cli.git.enable = true;
	cli.ssh.enable = true;
	terminal.kitty.enable = true;

	home.stateVersion = "25.11";
}
