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
}
