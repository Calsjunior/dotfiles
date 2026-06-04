{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  options.gui.browser.zen.enable = lib.mkEnableOption "Enable Zen Browser";

  config = lib.mkIf config.gui.browser.zen.enable {

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };

    home.sessionVariables = {
      BROWSER = "zen-beta";
    };
  };
}
