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

      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];

      initContent = ''
        export KEYTIMEOUT=5

        # Line editing binds
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^?' backward-delete-char
        bindkey '^h' backward-delete-char
        bindkey '^w' backward-kill-word
        bindkey '^y' autosuggest-accept
        bindkey -M viins '^P' up-line-or-history
        bindkey -M viins '^N' down-line-or-history

        # Ctrl+Space triggers fzf-tab completion
        bindkey '^@' fzf-tab-complete

        # Cursor shape for vi mode
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

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zmodload zsh/complist
        setopt MENU_COMPLETE

        # fzf-tab configuration
        zstyle ':fzf-tab:*' fzf-bindings 'tab:accept' 'ctrl-y:accept'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 --color=always --icons=always $realpath'
        zstyle ':fzf-tab:complete:*' fzf-preview '
          if [[ -d $realpath ]]; then
            eza --tree --level=1 --color=always --icons=always $realpath
          elif [[ -f $realpath ]]; then
            bat --color=always $realpath
          fi'
        zstyle ':fzf-tab:*' switch-group '<' '>'

        md2pdf() {
          pandoc "$1" -f markdown -o "''${1%.*}.pdf" --pdf-engine=tectonic -V geometry:margin=1in
          echo "Converted $1 to ''${1%.*}.pdf"
        }

      ''
      + lib.optionalString config.cli.starship.enable ''

        # Starship Transient Prompt Hook
        autoload -Uz add-zsh-hook
        autoload -Uz add-zle-hook-widget

        function transient_prompt_precmd() {
            # Capture the native Starship prompt strings only once
            if [[ -z "$STARSHIP_NORMAL_PROMPT" ]]; then
                STARSHIP_NORMAL_PROMPT=$'\n'"$PROMPT"
                STARSHIP_NORMAL_RPROMPT="$RPROMPT"
                
                STARSHIP_TRANSIENT_PROMPT="''${PROMPT// prompt / prompt --profile transient }"
                
                local temp_rprompt="''${RPROMPT// prompt / prompt --profile rtransient }"
                STARSHIP_TRANSIENT_RPROMPT="''${temp_rprompt// --right/}"
            fi
            
            # Always restore the normal prompt before rendering a new line
            PROMPT="$STARSHIP_NORMAL_PROMPT"
            RPROMPT="$STARSHIP_NORMAL_RPROMPT"
        }

        function transient_prompt_finish() {
            # Swap to the transient prompt right before the command executes
            PROMPT="$STARSHIP_TRANSIENT_PROMPT"
            RPROMPT="$STARSHIP_TRANSIENT_RPROMPT"
            zle .reset-prompt
        }

        # Register the hooks
        add-zsh-hook precmd transient_prompt_precmd
        add-zle-hook-widget zle-line-finish transient_prompt_finish

        # Fix ctrl+c behavior to ensure cancelled lines become transient too
        TRAPINT() {
            transient_prompt_finish
            return $(( 128 + $1 ))
        }
      '';
    };
  };
}
