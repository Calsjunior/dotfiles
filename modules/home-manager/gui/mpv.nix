{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gui.mpv = {
    enable = lib.mkEnableOption "Enable MPV Video Player with custom config";
  };

  config = lib.mkIf config.gui.mpv.enable {
    programs.mpv = {
      enable = true;
      package = pkgs.mpv.override {
        scripts = with pkgs.mpvScripts; [
          autoload
          autosub
          autosubsync-mpv
          modernz
          mpv-playlistmanager
          thumbfast
        ];
      };

      config = {
        # General
        profile = "high-quality";
        vo = "gpu-next";
        gpu-api = "vulkan";
        hwdec = "auto-safe";

        fullscreen = "yes";
        force-seekable = "yes";
        keep-open = "always";
        reset-on-next-file = "pause";

        dither-depth = 8;
        scale-antiring = 0.6;

        # Scalers and Shaders
        cscale = "ewa_lanczossharp";
        dscale = "mitchell";
        gpu-shader-cache-dir = "~~/shaders/cache";
        scale = "ewa_lanczossharp";

        # Debanding
        deband = "no";
        deband-grain = 12;
        deband-iterations = 2;
        deband-range = 17;
        deband-threshold = 64;

        # OSD & OSC
        border = "no";
        cursor-autohide = 300;
        cursor-autohide-fs-only = "yes";
        hr-seek = "yes";
        osc = "no";
        osd-bar = "no";
        osd-blur = 0.2;
        osd-border-color = "#000000";
        osd-border-size = 0.6;
        osd-color = "#FFFFFF";
        osd-duration = 1000;
        osd-font = "Verdana";
        osd-font-size = 20;
        osd-level = 1;

        # Language Priority
        alang = "en,eng";
        slang = "en,eng";

        # Audio
        audio-file-auto = "fuzzy";
        audio-pitch-correction = "yes";
        volume = 100;
        volume-max = 200;

        # Subtitles
        demuxer-mkv-subtitle-preroll = "yes";
        sub-fix-timing = "no";
        sub-auto = "all";
        sub-bold = "yes";
        sub-border-color = "#FF000000";
        sub-border-size = 2.0;
        sub-color = "#FFFFFFFF";
        sub-font-size = 40;
        sub-shadow-color = "#A0000000";
        sub-shadow-offset = 0.75;
        sub-spacing = 0.0;

        # Screenshot
        screenshot-directory = "${config.xdg.userDirs.pictures}/screenshots";
        screenshot-format = "png";
        screenshot-high-bit-depth = "yes";
        screenshot-png-compression = 1;
        screenshot-template = "%f-%wH.%wM.%wS.%wT-#%#00n";
      };

      scriptOpts = {
        modernz =
          let
            accent = "#3daee9";
          in
          {
            hover_effect_color = accent;
            nibble_color = accent;
            seek_handle_border_color = "disable";
            seek_handle_color = accent;
            seekbarfg_color = accent;
            window_controls = "no";
          };
      };

      profiles = {
        "WEB-DL" = {
          profile-desc = "WEB-DL Anime (HatSubs, SubsPlease, HorribleSubs, Erai-raws)";
          profile-cond = ''string.match(p.filename, "HatSubs")~=nil or string.match(p.filename, "SubsPlease")~=nil or string.match(p.filename, "HorribleSubs")~=nil or string.match(p.filename, "Erai%-raws")~=nil'';
          deband = "yes";
        };
      };

      bindings = {
        "l" = "seek 5";
        "h" = "seek -5";
        "L" = "seek 60";
        "H" = "seek -60";
        "ctrl+l" = "frame-step";
        "ctrl+h" = "frame-back-step";
        "k" = "add volume 2";
        "j" = "add volume -2";
        "K" = "add volume 10";
        "J" = "add volume -10";
        "SPACE" = "cycle pause";
        "P" = "script-binding playlistmanager/showplaylist";
        "gg" = "playlist-play-index 0";
        "ctrl+n" = "playlist-next";
        "ctrl+p" = "playlist-prev";
        "]" = "add speed 0.1";
        "[" = "add speed -0.1";
        "BS" = "set speed 1.0";
        "f" = "cycle fullscreen";
        "ctrl+o" = "cycle ontop";
        "d" = "cycle deband";
        "D" = "cycle deinterlace";
        "n" = "cycle video-unscaled";
        "C" = "cycle-values video-aspect-override \"16:9\" \"4:3\" \"2.35:1\" \"-1\"";
        "a" = "cycle audio";
        "A" = "cycle audio down";
        "s" = "cycle sub";
        "S" = "cycle sub down";
        "Shift+g" = "add sub-scale +0.05";
        "Shift+f" = "add sub-scale -0.05";
        "E" = "add sub-gauss +0.1";
        "R" = "add sub-gauss -0.1";
        "z" = "add sub-delay -0.05";
        "Z" = "add sub-delay +0.05";
        "u" = "cycle sub-gray";
        "U" = "cycle blend-subtitles";
        "p" = "cycle sub-fix-timing";
        "r" = "sub-reload";
        "WHEEL_UP" = "add volume 2";
        "WHEEL_DOWN" = "add volume -2";
        "UP" = "add volume 2";
        "DOWN" = "add volume -2";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "video/mp4" = "mpv.desktop";
        "video/matroska" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";
        "audio/aac" = "mpv.desktop";
      };
    };
  };
}
