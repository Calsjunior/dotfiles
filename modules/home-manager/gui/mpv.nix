{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.gui.mpv = {
    enable = lib.mkEnableOption "Enable MPV Video Player";
  };

  config = lib.mkIf config.gui.mpv.enable {
    programs.mpv = {
      enable = true;

      config = {
        profile = "gpu-hq";
        vo = "gpu-next";
        hwdec = "auto-safe";
        gpu-context = "wayland";

        keep-open = "yes";
        save-position-on-quit = "yes";
        osd-bar = "no";
        cursor-autohide = 1000;
      };

      bindings = {
        "WHEEL_UP" = "add volume 2";
        "WHEEL_DOWN" = "add volume -2";
        "UP" = "add volume 5";
        "DOWN" = "add volume -5";
        "RIGHT" = "seek  5";
        "LEFT" = "seek -5";
        "SPACE" = "cycle pause";
        "q" = "quit";
        "f" = "cycle fullscreen";
      };
    };
  };
}
