{ config, pkgs, ... }:
{
  home.username = "cal";
  home.homeDirectory = "/home/cal";

  wm.hyprland.enable = true;
  cli.shell.zsh.enable = true;
  cli.starship.enable = true;
  cli.neovim.enable = true;
  cli.yazi.enable = true;
  cli.git.enable = true;
  cli.ssh.enable = true;
  terminal.kitty.enable = true;

  home.stateVersion = "26.11";
}
