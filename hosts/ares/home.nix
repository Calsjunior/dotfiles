{
  config,
  pkgs,
  user,
  ...
}:
{
  home.username = user;
  home.homeDirectory = "/home/${user}";

  wm.hyprland.enable = true;
  cli.shell.zsh.enable = true;
  cli.core.enable = true;
  cli.docs.enable = true;
  cli.starship.enable = true;
  cli.neovim.enable = true;
  cli.yazi.enable = true;
  cli.git.enable = true;
  cli.ssh.enable = true;
  gui.kitty.enable = true;

  home.stateVersion = "26.11";
}
