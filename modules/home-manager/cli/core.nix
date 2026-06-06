{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    cli.core.enable = lib.mkEnableOption "Enable core CLI utilities";
  };

  config = lib.mkIf config.cli.core.enable {

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
    };

    home.packages = with pkgs; [
      fd
      ripgrep
      eza
    ];
  };
}
