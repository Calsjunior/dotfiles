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

  options = {
    cli.core.enable = lib.mkEnableOption "Enable core CLI utilities";
  };

  config = lib.mkIf config.cli.core.enable {

    home.packages = with pkgs; [
      fd
      ripgrep
      eza
      bat
      trash-cli
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ];

    programs.nix-index-database.comma.enable = true;

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = config.cli.shell.zsh.enable;
      defaultCommand = "fd --hidden";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
      historyWidgetOptions = [ "--preview-window hidden" ];
      defaultOptions = [
        "--scheme=path"
        "--tiebreak=end,length"
        "--preview 'if [[ -d {} ]]; then eza --tree --level=1 --color=always --icons=always {}; elif [[ -f {} ]]; then bat --color=always {}; fi'"
      ];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
      silent = true;
    };

    home = {
      sessionVariables = {
        _ZO_EXCLUDE_DIRS = "$HOME:$HOME/.local/*:$HOME/.cache/*:$HOME/.git/*:$HOME/node_modules/*";
      };

      shellAliases = {
        ls = "eza --icons -H --group-directories-first --git -1";
        rm = "echo 'Use trash (or \\\\rm to bypass and permanently delete)'";
        tp = "trash-put";
        te = "trash-empty";
        tl = "trash-list";
        tr = "trash-restore";
      };
    };

    home.file.".ignore".text = ''
      .local
      .cache
      .git
      node_modules
    '';
  };
}
