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
      enableZshIntegration = true;
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

    home.packages = with pkgs; [
      fd
      ripgrep
      eza
    ];
  };
}
