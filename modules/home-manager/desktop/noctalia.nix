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

    home.packages = [
      (pkgs.symlinkJoin {
        name = "noctalia-wrapped";
        paths = [ inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/noctalia \
            --prefix PATH : ${
              lib.makeBinPath (
                with pkgs;
                [
                  socat # Required by special workspaces, hypr-screen-mirror plugins
                ]
              )
            }
        '';
      })
    ];

    xdg.configFile."noctalia".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/noctalia";
  };
}
