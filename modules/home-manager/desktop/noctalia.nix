# Most styling related options of the shell are done via the GUI.
# See `../../../config/noctalia/settings.toml`
{
  config,
  dotfilesPath,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.noctalia;

  paths = cfg.extraPaths ++ lib.concatMap (p: p.extraPaths) (lib.attrValues cfg.plugins);

  noctalia =
    if paths == [ ] then
      pkgs.noctalia
    else
      pkgs.symlinkJoin {
        name = "noctalia-wrapped";
        paths = [ pkgs.noctalia ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/noctalia \
            --prefix PATH : ${lib.makeBinPath paths}
        '';
        meta = pkgs.noctalia.meta;
      };
in
{
  options.desktop.noctalia = {
    enable = lib.mkEnableOption "Enable Noctalia Shell Environment";

    extraPaths = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages added to Noctalia's PATH regardless of which plugins are enabled.";
    };

    storageKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file holding Noctalia's storage master key. Null leaves Noctalia on its default key source.";
    };

    plugins = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            settings = lib.mkOption {
              type = (pkgs.formats.toml { }).type;
              default = { };
              description = "Entry under [plugin_settings.\"<id>\"].";
            };
            extraPaths = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              description = "Packages this plugin needs on Noctalia's PATH.";
            };
          };
        }
      );
      default = { };
      description = "Enabled Noctalia plugins by plugin ID.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      package = noctalia;
      settings = {
        plugins = {
          auto_update = "none";
          enabled = lib.attrNames cfg.plugins;
          source = [
            {
              kind = "git";
              location = "https://github.com/noctalia-dev/official-plugins";
              name = "official";
            }
            {
              kind = "git";
              location = "https://github.com/noctalia-dev/community-plugins";
              name = "community";
            }
          ];
        };
        plugin_settings = lib.filterAttrs (_: s: s != { }) (lib.mapAttrs (_: p: p.settings) cfg.plugins);
      }
      // lib.optionalAttrs (cfg.storageKeyFile != null) {
        storage = {
          key_source = "file";
          key_file = cfg.storageKeyFile;
        };
      };
    };

    xdg.configFile."noctalia/settings.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/noctalia/settings.toml";
  };
}
