{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}:
{
  options = {
    desktop = {
      noctalia = {
        enable = lib.mkEnableOption "Enable Noctalia Shell Environment";
        extraPaths = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          internal = true;
        };
      };
      hasCompositor = lib.mkOption {
        type = lib.types.bool;
        default = false;
        internal = true;
      };
    };
  };

  config = lib.mkIf config.desktop.noctalia.enable {

    assertions = [
      {
        assertion = config.desktop.hasCompositor;
        message = "Noctalia Shell requires a graphical compositor module to be enabled.";
      }
    ];

    home.packages = [
      (
        if config.desktop.noctalia.extraPaths == [ ] then
          pkgs.noctalia
        else
          pkgs.symlinkJoin {
            name = "noctalia-wrapped";
            paths = [ pkgs.noctalia ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/noctalia \
                --prefix PATH : ${lib.makeBinPath config.desktop.noctalia.extraPaths}
            '';
          }
      )
    ];

    xdg.configFile."noctalia".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/noctalia";
  };
}
