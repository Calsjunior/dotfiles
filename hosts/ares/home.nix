{ config, ... }:
{
  imports = [
    ../shared/home.nix
  ];

  home.sessionVariables = {
    PRIMARY_MONITOR = "DP-1";
  };

  home.file.".ignore".text = ''
    games
  '';

  gui.gaming = {
    enable = true;
    lutris.gamePath = "${config.home.homeDirectory}/games/library";
  };
}
