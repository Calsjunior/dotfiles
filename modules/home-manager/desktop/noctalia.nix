{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    desktop.noctalia.enable = lib.mkEnableOption "Enable Noctalia Shell Environment";
  };

  config = lib.mkIf config.desktop.noctalia.enable {

    assertions = [
      {
        assertion = lib.any (x: x) [
          config.desktop.hyprland.enable
        ];
        message = "Noctalia Shell requires at least one graphical compositor module to be enabled.";
      }
    ];

    home.packages = with pkgs; [
      inputs.noctalia.packages.${pkgs.system}.default
      gpu-screen-recorder
    ];

    xdg.configFile."noctalia".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/noctalia";
  };
}
