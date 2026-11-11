{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  options.cli.core.enable = lib.mkEnableOption "core CLI utilities";

  config = lib.mkIf config.cli.core.enable {
    programs.man.generateCaches = true;

    programs.nix-index-database.comma.enable = true;

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = config.cli.shell.zsh.enable;
      defaultCommand = "fd --hidden --color=always";
      changeDirWidget.command = "fd --type d --color=always";
      fileWidget.command = "fd --type f --color=always";
      historyWidget.options = [ "--preview-window hidden" ];
      defaultOptions = [
        "--ansi"
        "--scheme=path"
        "--tiebreak=end,length"
        "--preview 'if [[ -d {} ]]; then eza --tree --level=1 --color=always --icons=always {}; elif [[ -f {} ]]; then bat --color=always {}; fi'"
        "--bind=ctrl-y:accept"
      ];
    };

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
      silent = true;
      stdlib = /* bash */ ''
        : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          local hash path
          echo "''${direnv_layout_dirs[$PWD]:=$(
            hash="''$(sha1sum - <<< "$PWD" | head -c40)"
            path="''${PWD//[^a-zA-Z0-9]/-}"
            echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
          )}"
        }
      '';
    };

    programs.aria2 = {
      enable = true;
      settings = {
        bt-max-peers = 0;
        bt-request-peer-speed-limit = "10M";
        continue = true;
        disk-cache = "64M";
        file-allocation = "none";
        max-concurrent-downloads = 8;
        max-connection-per-server = 16;
        min-split-size = "1M";
        optimize-concurrent-downloads = true;
        split = 16;
      };
    };

    home =
      let
        ignoreDirs = [
          ".local"
          ".cache"
          ".git"
          ".npm"
          ".config"
          "node_modules"
        ];
        ignoreFiles = [
          "package-lock.json"
          "flake.lock"
        ];
      in
      {
        packages = with pkgs; [
          fd
          eza
          bat
          trash-cli
        ];

        file.".ignore".text = lib.concatStringsSep "\n" (ignoreDirs ++ ignoreFiles) + "\n";

        sessionVariables = {
          _ZO_EXCLUDE_DIRS = lib.concatStringsSep ":" ([ "$HOME" ] ++ map (dir: "$HOME/${dir}/*") ignoreDirs);
        };

        shellAliases = {
          ls = "eza --icons -H --group-directories-first --git -1";
          rm = "echo 'Use trash (or \\\\rm to bypass and permanently delete)'; false";
          tp = "trash-put";
          te = "trash-empty";
          tl = "trash-list";
          tr = "trash-restore";
        };
      };
  };
}
