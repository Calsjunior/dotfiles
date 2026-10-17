{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.gui.gaming = {
    enable = lib.mkEnableOption "Lutris, MangoHud and gaming tools";

    lutris.gamePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/mnt/hdd/games/library";
      description = "Optional game directory used by Lutris.";
    };
  };

  config = lib.mkIf config.gui.gaming.enable {
    programs.lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
        gamemode
      ];

      runners.wine.settings.system = {
        env = {
          DXVK_STATE_CACHE_PATH = "${config.home.homeDirectory}/.cache/dxvk";
          DXVK_HUD = "0";
          PROTON_ENABLE_NVAPI = "1";
          PROTON_ENABLE_WAYLAND = "1"; # Forces native wayland, could break in some games
        };
      };
    };

    xdg.configFile."lutris/system.yml".text = lib.generators.toYAML { } {
      system = {
        disable_runtime = true;
        mangohud = true;
        gamemode = true;
        env = {
          MANGOHUD_CONFIG = "fps,cpu_temp,gpu_temp,ram,toggle_hud=grave,no_display";
          __GL_SHADER_DISK_CACHE_PATH = "${config.home.homeDirectory}/.cache/nvidia";
        };
      }
      // lib.optionalAttrs (config.gui.gaming.lutris.gamePath != null) {
        game_path = config.gui.gaming.lutris.gamePath;
      };
    };
  };
}
