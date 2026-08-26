{
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
    wayland.enable = true;
  };

  cli = {
    shell.zsh.enable = true;
    core.enable = true;
    oh-my-posh.enable = true;
    neovim.enable = true;
    git.enable = true;
    ssh.enable = true;
    scripts.enable = true;
    formatters.enable = true;
    yazi = {
      enable = true;
      terminalCmd = "${pkgs.kitty}/bin/kitty";
    };
  };

  gui = {
    kitty.enable = true;
    browser.zen.enable = true;
    comms.enable = true;
    mpv.enable = true;
    documents.enable = true;
  };
}
