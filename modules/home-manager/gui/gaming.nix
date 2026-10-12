{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.gui.gaming.enable = lib.mkEnableOption "Lutris, MangoHud and gaming tools";

  config = lib.mkIf config.gui.gaming.enable {
    programs.lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
        gamemode
        winetricks
        wineWow64Packages.stable
      ];

      runners.wine.settings.system = {
        env = {
          DXVK_CONFIG = "dxvk.trackPipelineLifetime = True"; # Fixes memory leak
          DXVK_ENABLE_NVAPI = "1";
          DXVK_STATE_CACHE_PATH = "${config.home.homeDirectory}/.cache/dxvk";
          DXVK_HUD = "0";
        };
      };
    };

    home.file."games" = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/hdd/games";
    };

    xdg.configFile."lutris/system.yml".text = /* yaml */ ''
      system:
        game_path: /mnt/hdd/games/library
        mangohud: true
        env:
          MANGOHUD_CONFIG: "fps,cpu_temp,gpu_temp,ram,toggle_hud=grave,no_display"
          __GL_SHADER_DISK_CACHE_PATH: "${config.home.homeDirectory}/.cache/nvidia"
    '';
  };
}
