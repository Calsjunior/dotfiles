{
  config,
  ...
}:
let
  hdd = "/mnt/hdd";
  gamesPath = "${hdd}/games";
  videosPath = "${hdd}/videos";
  imagesPath = "${hdd}/pictures";
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
    "Videos/library".source = config.lib.file.mkOutOfStoreSymlink videosPath;
    "Pictures/library".source = config.lib.file.mkOutOfStoreSymlink imagesPath;
  };
}
