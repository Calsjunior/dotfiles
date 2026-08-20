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
        wl-clipboard # Required by the 'clipboard' plugin
      ];

      initLua = ''
        -- Fix directories blue color icon
        function Entity:icon()
          local icon = th.icon:match(self._file)
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
                "plugin ucp copy notify"
              ];
              desc = "Yank selected files (copy)";
            }
            {
              on = [ "p" ];
              run = [ "plugin ucp paste notify" ];
              desc = "Paste yanked system clipboard files";
            }
          ];
        };
      };

      plugins = with pkgs.yaziPlugins; {
        chmod.package = chmod;
        smart-filter.package = smart-filter;
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

        ucp = {
          package = pkgs.fetchFromGitHub {
            owner = "simla33";
            repo = "ucp.yazi";
            rev = "79043fbbfd39b7b9ae0142d11b315272dd90d33b";
            hash = "sha256-oL3fss8/U6IH2y5B/YdK17h4LvN4XsPypmC+yzJBMnE=";
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
      };
    };
  };
}
