{
  config,
  ...
}:
let
  hdd = "/mnt/hdd";
  gamesPath = "${hdd}/games";
in
{
  imports = [
    ../shared/home.nix
  ];

  home.sessionVariables = {
    PRIMARY_MONITOR = "DP-1";
  };

  gui.gaming = {
    enable = true;
    lutris.gamePath = "${gamesPath}/library";
  };

  home.file = {
    "games".source = config.lib.file.mkOutOfStoreSymlink gamesPath;
  };
}
