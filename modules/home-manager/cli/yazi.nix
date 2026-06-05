{
  config,
  lib,
  pkgs,
  ...
}:
let
  yazi-wrapper = pkgs.writeShellScriptBin "yazi-wrapper" ''
    #!/usr/bin/env bash

    out_path="$1"
    shift

    if [ "$#" -ge 1 ]; then
      exec yazi --chooser-file="$out_path" "$1"
    else
      exec yazi --chooser-file="$out_path"
    fi
  '';
in
{
  options.cli.yazi = {
    enable = lib.mkEnableOption "Enable Yazi";

    terminalCmd = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.kitty}/bin/kitty";
      description = "The terminal command used to launch GUI instances of Yazi (must support -e flag).";
    };
  };

  config = lib.mkIf config.cli.yazi.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = config.cli.shell.zsh.enable;

      initLua = ''
        require("full-border"):setup()
      '';

      plugins = {
        full-border = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/full-border.yazi";
      };
    };

    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      # Route the request through our new wrapper script instead of calling Yazi directly
      cmd=${config.cli.yazi.terminalCmd} --class termfilechooser -e ${yazi-wrapper}/bin/yazi-wrapper %s
    '';

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-termfilechooser
      ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
    };
  };
}
