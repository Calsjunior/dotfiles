{
  config,
  lib,
  pkgs,
  ...
}:
let
  vesktopDir = "${config.xdg.configHome}/vesktop";

  vesktopSettings = {
    minimizeToTray = false;
  };

  vencordSettings = {
    enabledThemes = [
      "discord-system24.css"
    ];
    plugins = {
      FakeNitro.enabled = true;
      VolumeBooster.enabled = true;
      BetterFolders.enabled = true;
    };
  };

  declared = name: attrs: pkgs.writeText name (builtins.toJSON attrs);

  mergeJson = pkgs.writeShellApplication {
    name = "merge-json";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      target=$1
      declared=$2

      if [ -L "$target" ]; then
        rm "$target"
      fi

      if [ ! -f "$target" ]; then
        echo '{}' > "$target"
      fi

      jq -s '.[0] * .[1]' "$target" "$declared" > "$target.tmp"
      mv "$target.tmp" "$target"
    '';
  };
in
{
  options = {
    gui.comms.enable = lib.mkEnableOption "Enable Communication Apps";
  };

  config = lib.mkIf config.gui.comms.enable {
    home.packages = with pkgs; [
      telegram-desktop
    ];

    programs.vesktop.enable = true;

    home.activation.mergeVesktop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${vesktopDir}/settings"
      ${lib.getExe mergeJson} "${vesktopDir}/settings.json" ${declared "vesktop.json" vesktopSettings}
      ${lib.getExe mergeJson} "${vesktopDir}/settings/settings.json" ${declared "vencord.json" vencordSettings}
    '';
  };
}
