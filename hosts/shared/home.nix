{
  config,
  lib,
  osConfig,
  pkgs,
  user,
  ...
}:
{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.11";
  };

  desktop = {
    hyprland.enable = true;
    noctalia = {
      enable = true;
      storageKeyFile = osConfig.sops.secrets.noctalia_storage_key.path or null;
      plugins = lib.mkMerge [
        {
          "noctalia/notes".settings.notes_dir = "${config.xdg.userDirs.documents}/notes";
          "noctalia/screen_recorder".settings = {
            audio_source = "both";
            color_range = "full";
            copy_to_clipboard = true;
            directory = "~/Videos/recordings";
            video_encoder = "cpu";
            video_source = "focused";
          };
          "thepunkoff/pomodoro" = { };
          "fel/ocr".extraPaths = with pkgs; [
            tesseract
            grim
            slurp
          ];
        }
        (lib.mkIf (osConfig.sys.printing.enable or false) {
          "andrewdems/printers" = {
            settings.poll_interval_seconds = 300;
            extraPaths = with pkgs; [ system-config-printer ];
          };
        })
      ];
    };
    theme.enable = true;
    wayland.enable = true;
  };

  cli = {
    shell.zsh.enable = true;
    core.enable = true;
    oh-my-posh.enable = true;
    neovim.enable = true;
    git.enable = true;
    ssh.enable = true;
    scripts.enable = true;
    formatters.enable = true;
    yazi = {
      enable = true;
      terminalCmd = "${pkgs.kitty}/bin/kitty";
    };
  };

  gui = {
    kitty.enable = true;
    browser.zen.enable = true;
    comms.enable = true;
    mpv.enable = true;
    documents.enable = true;
  };
}
