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

    # Extra tools used in yazi
    home.packages = with pkgs; [
      ripgrep # Required by the 'fr' plugin
      trash-cli # Required by the 'recycle-bin' plugin
      wl-clipboard # Required by the 'ucp' plugin
      xdg-desktop-portal-termfilechooser
    ];

    programs.yazi = {
      enable = true;
      enableZshIntegration = config.cli.shell.zsh.enable;

      initLua = ''
        require("full-border"):setup()
        require("recycle-bin"):setup()
        require("simple-tag"):setup({
            ui_mode = "icon",
            colors = {
                ["c"] = "green",
            },
            icons = {
                ["c"] = "󰄲 ",
            },
        })

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

      settings = {
        plugin = {
          prepend_fetchers = [
            {
              id = "simple-tag";
              url = "*";
              run = "simple-tag";
              group = "simple-tag";
            }
            {
              id = "simple-tag";
              url = "*/";
              run = "simple-tag";
              group = "simple-tag";
            }
          ];
        };
      };

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
              run = "plugin ucp copy";
              desc = "Copy";
            }
            {
              on = [ "p" ];
              run = "plugin ucp paste";
              desc = "Paste";
            }
            {
              on = [
                "R"
                "b"
              ];
              run = "plugin recycle-bin";
              desc = "Open Recycle Bin menu";
            }
            {
              on = [
                "T"
                "t"
                "K"
              ];
              run = "plugin simple-tag -- toggle-tag";
              desc = "Toggle a tag";
            }
            {
              on = [
                "T"
                "a"
                "k"
              ];
              run = "plugin simple-tag -- add-tag";
              desc = "Add a tag";
            }
            {
              on = [
                "T"
                "d"
                "k"
              ];
              run = "plugin simple-tag -- remove-tag";
              desc = "Remove a tag";
            }
            {
              on = [
                "T"
                "n"
              ];
              run = "plugin simple-tag -- filter --mode=not";
              desc = "Filter only untagged items";
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

        recycle-bin = pkgs.fetchFromGitHub {
          owner = "uhs-robert";
          repo = "recycle-bin.yazi";
          rev = "main";
          hash = "sha256-lpxTGWA15szM5VJ+qvV2+GTg7HXiZaZfyWyjeNMsTSM=";
        };

        simple-tag = pkgs.fetchFromGitHub {
          owner = "boydaihungst";
          repo = "simple-tag.yazi";
          rev = "e8be0311282605c877be33587b3cb0eb4cf852e6";
          hash = "sha256-qtCoDSt5dWTxJC2xB/iufmOSO13joEIFl4A2D4ohIyE=";
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
            env=PATH="$PATH:/run/current-system/${config.home.profileDirectory}/bin"
            open_mode=suggested
            save_mode=last
          '';
        };
      };
    };
  };
}
