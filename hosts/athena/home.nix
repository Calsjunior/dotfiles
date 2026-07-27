{
  config,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../shared/home.nix
  ];

  home.sessionVariables = {
    PRIMARY_MONITOR = "eDP-1";
  };
}
