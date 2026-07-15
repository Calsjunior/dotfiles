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

    desktop.termfilechooser = {
      enable = true;
      wrapperCmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
      terminalCmd = config.cli.yazi.terminalCmd;
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = config.cli.shell.zsh.enable;

      # Extra tools used in this config
      package = pkgs.symlinkJoin {
        name = "yazi-wrapped";
        paths = [ pkgs.yazi ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/yazi \
            --prefix PATH : ${
              pkgs.lib.makeBinPath (
                with pkgs;
                [
                  ripgrep # Required by the 'fr' plugin
                  trash-cli # Required by the 'recycle-bin' plugin
                  wl-clipboard # Required by the 'ucp' plugin
                  fzf # Required for portal file picker context
                  fd # Required for portal file picker context
                  zoxide # Required for portal file picker context
                ]
              )
            } \
            --set FZF_DEFAULT_COMMAND "${
              if config.programs.fzf.defaultCommand != null then
                config.programs.fzf.defaultCommand
              else
                "fd --hidden"
            }" \
            --set _ZO_EXCLUDE_DIRS "${config.home.sessionVariables._ZO_EXCLUDE_DIRS or ""}" \
            --set RIPGREP_CONFIG_PATH "${pkgs.writeText "yazi-rg.conf" ''
              --glob=!package-lock.json
              --glob=!package.json
              --glob=!pnpm-lock.yaml
              --glob=!yarn.lock
            ''}"
        '';
      };

      initLua = ''
        require("full-border"):setup()
        require("recycle-bin"):setup()
        require("git"):setup({
          order = 1500,
        })
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
            {
              url = "*";
              run = "git";
              group = "git";
            }
            {
              url = "*/";
              run = "git";
              group = "git";
            }
          ];
        };
      };

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = [ "f" ];
              run = "plugin jump-to-char";
              desc = "Jump to character";
            }
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

        git = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/git.yazi";

        jump-to-char = "${
          pkgs.fetchFromGitHub {
            owner = "yazi-rs";
            repo = "plugins";
            rev = "main";
            hash = "sha256-bqGN6JxbU+/o7TlM/Cm9Qj/s1McA4pB5QWArGZPcme4=";
          }
        }/jump-to-char.yazi";

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
  };
}
