{
  pkgs,
  ...
}:
{
  imports = [
    ../shared/home.nix
  ];

  home.sessionVariables = {
    PRIMARY_MONITOR = "eDP-1";
  };

  cli = {
    media.enable = true;
  };

  desktop = {
    noctalia.plugins = {
      "profidev/hypr-screen-mirror".extraPaths = with pkgs; [ socat ];
    };
  };
}
