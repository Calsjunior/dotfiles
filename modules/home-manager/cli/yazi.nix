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

      initLua = /* lua */ ''
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

        -- Navigation history: records visited directories and hovered files
        local HOME = os.getenv("HOME")
        local CONFIG = {
          log_path   = (os.getenv("XDG_STATE_HOME") or (HOME .. "/.local/state")) .. "/yazi-recent",
          max_lines  = 5000, -- trim the log once it grows past this
          keep_lines = 3000, -- ...down to this many unique, newest entries
          hover_secs = 1.5, -- time required on a file to log it
          cd_secs    = 1.0, -- time required inside a directory to log it
          ignored    = { [HOME] = true, ["/"] = true }, -- directories never logged
        }

        local function write_lines(path, mode, lines)
          local f = io.open(path, mode)
          if not f then return false end
          for _, line in ipairs(lines) do f:write(line, "\n") end
          f:close()
          return true
        end

        local function read_lines(path)
          local f = io.open(path, "r")
          if not f then return {} end
          local lines = {}
          for line in f:lines() do lines[#lines + 1] = line end
          f:close()
          return lines
        end

        local function latest_unique(lines, limit)
          local seen, kept = {}, {}
          for i = #lines, 1, -1 do
            local line = lines[i]
            if not seen[line] then
              seen[line] = true
              kept[#kept + 1] = line
              if #kept >= limit then break end
            end
          end
          return kept
        end

        local function reversed(list)
          local out = {}
          for i = #list, 1, -1 do out[#out + 1] = list[i] end
          return out
        end

        local Log = {}
        Log.__index = Log

        function Log.new(path, max_lines, keep_lines)
          return setmetatable({ path = path, max = max_lines, keep = keep_lines, last = nil }, Log)
        end

        function Log:append(entry)
          if entry == self.last then return end
          if write_lines(self.path, "a", { entry }) then
            self.last = entry
          end
        end

        function Log:trim()
          local lines = read_lines(self.path)
          if #lines <= self.max then return end
          write_lines(self.path, "w", reversed(latest_unique(lines, self.keep)))
        end

        local log = Log.new(CONFIG.log_path, CONFIG.max_lines, CONFIG.keep_lines)
        log:trim()

        -- Separate tokens to prevent file hovers from interrupting directory timers
        local dir_token = 0
        local file_token = 0

        ps.sub("cd", function()
          dir_token = dir_token + 1
          file_token = file_token + 1 -- changing directories cancels active file hover timers
          local mine = dir_token

          local cwd = tostring(cx.active.current.cwd)
          if CONFIG.ignored[cwd] then
            return
          end

          local ok, err = pcall(ya.async, function()
            ya.sleep(CONFIG.cd_secs)
            if mine == dir_token then -- still inside this directory after cd_secs
              log:append(cwd .. "/")
            end
          end)

          if not ok then
            ya.err("recent: could not start cd timer: " .. tostring(err))
          end
        end)

        ps.sub("hover", function()
          file_token = file_token + 1
          local mine = file_token

          local hovered = cx.active.current.hovered
          if not hovered or hovered.cha.is_dir then
            return
          end

          local url = tostring(hovered.url)
          local ok, err = pcall(ya.async, function()
            ya.sleep(CONFIG.hover_secs)
            if mine == file_token then -- still resting on the same file
              log:append(url)
            end
          end)

          if not ok then
            ya.err("recent: could not start hover timer: " .. tostring(err))
          end
        end)
      '';

      /*nixfmt:disable*/
      settings = {
        mgr = {
          sort_by = "natural";
        };
        plugin = {
          prepend_fetchers = [
            { url = "*";  run = "git"; group = "git"; }
            { url = "*/"; run = "git"; group = "git"; }
          ];
        };
      };

      keymap =
      let
        recent = pkgs.writeShellScript "yazi-recent" ''
          f="''${XDG_STATE_HOME:-$HOME/.local/state}/yazi-recent"
          [ -r "$f" ] || exit 0
          cd "$HOME" || exit 1

          sel=$(
            tac "$f" | awk '!seen[$0]++' \
              | sed "s#^$HOME/##" | grep -v '^$' \
              | xargs -d '\n' ${pkgs.eza}/bin/eza -1d --classify=always --color=always --no-quotes --sort=none 2>/dev/null \
              | sed -E 's/ \x1b\[[0-9;]*m->.*$//' \
              | ${pkgs.fzf}/bin/fzf --ansi
          ) || exit 0

          [[ $sel == /* ]] || sel="$HOME/$sel"
          [ -e "$sel" ] || sel=''${sel%[*@=|]}
          [ -d "$sel" ] && action=cd || action=reveal
          ya emit "$action" "$sel"
        '';
      in {
        mgr = {
          prepend_keymap = [
            { on = [ "F" ];     run = "plugin smart-filter";         desc = "Smart Filter"; }
            { on = [ "S" ];     run = "plugin fr rg";                desc = "Search file by content"; }
            { on = [ "c" "m" ]; run = "plugin chmod";                desc = "Chmod on selected files"; }
            { on = [ "p" ];     run = [ "plugin ucp paste notify" ]; desc = "Paste yanked system clipboard files"; }
            { on = [ "y" ];     run = [ "plugin ucp copy notify" ];  desc = "Yank selected files (copy)"; }
            { on = [ "i" ];     run = [ "plugin easyjump" ];         desc = "Easyjump"; }
            { on = [ "g" "r" ]; run = "shell '${recent}' --block";   desc = "Recent dir and files (fzf)"; }
          ];
        };
      };
      /*nixfmt:enable*/

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
        easyjump = {
          package = easyjump;
          setup = true;
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
