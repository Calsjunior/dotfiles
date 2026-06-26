{
  config,
  pkgs,
  user,
  ...
}:
{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.11";
  };

  desktop = {
    hyprland.enable = true;
    noctalia.enable = true;
    theme.enable = true;
  };

  cli = {
    shell.zsh.enable = true;
    core.enable = true;
    docs.enable = true;
    starship.enable = true;
    neovim.enable = true;
    git.enable = true;
    ssh.enable = true;
    wayland-tools.enable = true;
    yazi = {
      enable = true;
      terminalCmd = "${pkgs.kitty}/bin/kitty";
    };
    formatters.enable = true;
  };

  gui = {
    kitty.enable = true;
    browser.zen.enable = true;
    comms.enable = true;
    mpv.enable = true;
  };
}
