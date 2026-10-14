{ config, ... }:
{
  imports = [
    ../shared/home.nix
  ];

  home.sessionVariables = {
    PRIMARY_MONITOR = "DP-1";
  };

  gui.gaming = {
    enable = true;
    lutris.gamePath = "${config.home.homeDirectory}/games/library";
  };
}
