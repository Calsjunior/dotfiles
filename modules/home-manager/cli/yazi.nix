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
      extraPackages = with pkgs; [
        trash-cli # Required by the 'recycle-bin' plugin
        wl-clipboard # Required by the 'clipboard' plugin
      ];

      initLua = ''
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
        mgr = {
          sort_by = "natural";
        };
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
              run = [
                "yank"
                "plugin clipboard -- --action=copy"
              ];
              desc = "Yank selected files (copy)";
            }
            {
              on = [ "x" ];
              run = [
                "yank --cut"
                "plugin clipboard -- --action=copy"
              ];
              desc = "Yank selected files (cut)";
            }
            {
              on = [ "p" ];
              run = [ "plugin clipboard -- --action=paste" ];
              desc = "Paste yanked system clipboard files";
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

      plugins = with pkgs.yaziPlugins; {
        chmod.package = chmod;
        smart-filter.package = smart-filter;
        clipboard.package = clipboard;
        full-border = {
          package = full-border;
          setup = true;
        };

        git = {
          package = git;
          setup = true;
          settings = {
            order = 1500;
          };
        };

        fr = {
          package = pkgs.fetchFromGitHub {
            owner = "lpnh";
            repo = "fr.yazi";
            rev = "aa88cd4d4345c07345275291c1a236343f834c86";
            hash = "sha256-3D1mIQpEDik0ppPQo+/NIhCxEu/XEnJMJ0HiAFxlOE4=";
          };
        };

        recycle-bin = {
          package = pkgs.fetchFromGitHub {
            owner = "uhs-robert";
            repo = "recycle-bin.yazi";
            rev = "82da16ad6471616e383f41532b703d41210167eb";
            hash = "sha256-lpxTGWA15szM5VJ+qvV2+GTg7HXiZaZfyWyjeNMsTSM=";
          };
          setup = true;
        };

        simple-tag = {
          package = pkgs.fetchFromGitHub {
            owner = "boydaihungst";
            repo = "simple-tag.yazi";
            rev = "e8be0311282605c877be33587b3cb0eb4cf852e6";
            hash = "sha256-qtCoDSt5dWTxJC2xB/iufmOSO13joEIFl4A2D4ohIyE=";
          };
          setup = true;
          settings = {
            ui_mode = "icon";
            colors = {
              c = "green";
            };
            icons = {
              c = "󰄲 ";
            };
          };
        };
      };
    };
  };
}
