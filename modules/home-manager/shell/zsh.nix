{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  options = {
    cli.shell.zsh.enable = lib.mkEnableOption "Enable Zsh Configuration";
  };
  config = lib.mkIf config.cli.shell.zsh.enable {

    # Ensure core CLI tools are available for Zsh aliases
    cli.core.enable = lib.mkDefault true;
    assertions = [
      {
        assertion = osConfig.sys.shell.zsh.enable;
        message = "Home Manager Zsh requires the system-level Zsh module (sys.shell.zsh.enable = true).";
      }
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      defaultKeymap = "viins";
      history = {
        size = 100000;
        save = 100000;
        path = "${config.home.homeDirectory}/.zsh_history";
        share = true;
        ignoreDups = true;
        ignoreSpace = true;
      };
      shellAliases = {
        f = "find . -iname";
        g = "grep --color=auto -R";
        ls = "eza --icons -H --group-directories-first --git -1";
      };
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          TRANSIENT_PROMPT_TRANSIENT_PROMPT='$(starship module character)'
        '')
        ''
          export KEYTIMEOUT=5
          bindkey '^R' history-incremental-search-backward
          bindkey '^A' beginning-of-line
          bindkey '^E' end-of-line
          bindkey '^?' backward-delete-char
          bindkey '^h' backward-delete-char
          bindkey '^w' backward-kill-word
          bindkey -M viins '^P' up-line-or-history
          bindkey -M viins '^N' down-line-or-history
          function zle-keymap-select {
              if [[ ''${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
                  echo -ne '\e[1 q'
              elif [[ ''${KEYMAP} == main ]] || [[ ''${KEYMAP} == viins ]] || [[ ''${KEYMAP} = "" ]] || [[ $1 = 'beam' ]]; then
                  echo -ne '\e[5 q'
              fi
          }
          zle -N zle-keymap-select
          zle-line-init() {
              zle -K viins
              echo -ne "\e[5 q"
          }
          zle -N zle-line-init
          zstyle ':completion:*' menu select
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zmodload zsh/complist
          setopt MENU_COMPLETE
          bindkey '^@' menu-complete
          bindkey -M menuselect '^n' down-line-or-history
          bindkey -M menuselect '^p' up-line-or-history
          bindkey -M menuselect '^[[13;5u' accept-line
          bindkey '^[[13;5u' autosuggest-accept
          bindkey -M menuselect '^y' accept-line
          bindkey '^y' autosuggest-accept
          md2pdf() {
              pandoc "$1" -f markdown -o "''${1%.*}.pdf" --pdf-engine=tectonic -V geometry:margin=1in
              echo "Converted $1 to ''${1%.*}.pdf"
          }
        ''
        (lib.mkAfter ''
          source ${
            pkgs.fetchFromGitHub {
              owner = "olets";
              repo = "zsh-transient-prompt";
              rev = "v1.0.1";
              sha256 = "sha256-v4RuB/LL5/6d0FPDPrheFN5o1ZXKjIbfThz/sKSEuII=";
            }
          }/transient-prompt.plugin.zsh
        '')
      ];
    };
  };
}
