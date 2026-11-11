{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gui.comms.enable = lib.mkEnableOption "communication apps";

  config = lib.mkIf config.gui.comms.enable {
    home.packages = with pkgs; [ telegram-desktop ];

    programs.vesktop = {
      enable = true;
      mutableSettings = true;
      settings.minimizeToTray = false;

      vencord = {
        mutableSettings = true;
        settings = {
          useQuickCss = true;
          enabledThemes = [ "discord-system24.css" ];
          plugins = {
            FakeNitro.enabled = true;
            VolumeBooster.enabled = true;
            BetterFolders.enabled = true;
          };
        };

        extraQuickCss = /* css */ ''
          [class*="winButtons"] {
            display: none !important;
          }
        '';
      };
    };
  };
}
