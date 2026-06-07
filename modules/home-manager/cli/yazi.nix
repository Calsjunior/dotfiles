{
  config,
  lib,
  pkgs,
  ...
}:
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

        -- Fix directories blue color icon
        function Entity:icon()
          local icon = self._file:icon()
            if not icon then
                return ui.Span("")
            end

            local span = ui.Span(icon.text .. " ")

            local hovered = cx.active.current.hovered
            if hovered and tostring(hovered.url) == tostring(self._file.url) then
                return span
            end

            if self._file.cha.is_dir then
                return span:fg("blue")
            end

            if icon.style then
                return span:style(icon.style)
            else
                return span
            end
        end
      '';

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
              desc = "Chmod on selected files";
            }
            {
              on = [ "F" ];
              run = "plugin smart-filter";
              desc = "Smart Filter";
            }
            {
              on = [ "S" ];
              run = "plugin fr rg";
              desc = "Search file by content";
            }
            {
              on = [ "y" ];
              run = "plugin ucp copy notify";
              desc = "Copy";
            }
            {
              on = [ "P" ];
              run = "plugin ucp paste notify";
              desc = "Paste";
            }
          ];
        };
      };

      plugins = {
        full-border = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/full-border.yazi";

        chmod = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/chmod.yazi";

        smart-filter = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/smart-filter.yazi";

        fr = pkgs.fetchFromGitHub {
          owner = "lpnh";
          repo = "fr.yazi";
          rev = "main";
          hash = "sha256-3D1mIQpEDik0ppPQo+/NIhCxEu/XEnJMJ0HiAFxlOE4=";
        };

        ucp = pkgs.fetchFromGitHub {
          owner = "simla33";
          repo = "ucp.yazi";
          rev = "main";
          hash = "sha256-jIvooR00smQb8bmS3slj87k4yM9aTeruvhu/1krigZ8=";
        };
      };
    };

    xdg = {
      enable = true;
      configFile = {
        "xdg-desktop-portal-termfilechooser/config" = {
          enable = true;
          force = true;
          text = ''
            [filechooser]
            cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
            default_dir=$HOME/Downloads
            env=TERMCMD=${config.cli.yazi.terminalCmd} --class termfilechooser -e
            env=PATH="$PATH:/run/current-system/sw/bin"
            open_mode=suggested
            save_mode=last
          '';
        };
      };

      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-termfilechooser
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          };
        };
      };
    };
  };
}
