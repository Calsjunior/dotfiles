# =============================================================================
#  ZINIT
# =============================================================================
source /usr/share/zinit/zinit.zsh

# =============================================================================
#  ZSH HISTORY
# =============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE

# =============================================================================
#  VIM MODE & CURSOR FIXES
# =============================================================================
bindkey -v
export KEYTIMEOUT=1

bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history

function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init

# =============================================================================
#  COMPLETION SETTINGS
# =============================================================================
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zmodload zsh/complist

# =============================================================================
#  CUSTOM KEYBINDINGS
# =============================================================================
setopt MENU_COMPLETE
bindkey '^@' menu-complete
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
bindkey -M menuselect '^[[13;5u' accept-line
bindkey '^[[13;5u' autosuggest-accept
bindkey -M menuselect '^y' accept-line
bindkey '^y' autosuggest-accept

# =============================================================================
#  ALIASES
# =============================================================================
alias v="nvim"
alias f="find . -iname"
alias g="grep --color=auto -R"
alias ls='eza --icons -H --group-directories-first --git -1'
alias recent-installs='expac --timefmt="%Y-%m-%d %T" "%l\t%n" $(pacman -Qqe) | sort'

md2pdf() {
    pandoc "$1" -f markdown -o "${1%.*}.pdf" --pdf-engine=tectonic -V geometry:margin=1in
    echo "Converted $1 to ${1%.*}.pdf"
}

# =============================================================================
#  PLUGINS (zinit turbo mode - deferred after prompt)
# =============================================================================
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid blockf
zinit light zsh-users/zsh-completions

# Defer compinit until after prompt
autoload -Uz compinit
zinit ice wait"0" lucid atinit"compinit -C -d ~/.zcompdump"
zinit light zdharma-continuum/null

# =============================================================================
#  INITIALIZATION
# =============================================================================

# Lazy Load NVM
declare -a nvm_triggers=(node npm nvm pnpm yarn)
for cmd in $nvm_triggers; do
    eval "$cmd() { unset -f $nvm_triggers; source /usr/share/nvm/init-nvm.sh; $cmd \"\$@\"; }"
done

# Tools
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)

# Fastfetch
if [[ $(tty) == *"pts"* ]] && [[ -z "$ZSH_EXECUTION_STRING" ]]; then
    if [ -f "$HOME/.config/fastfetch/config.jsonc" ]; then
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
    else
        fastfetch
    fi
else
    if [ -f /bin/hyprctl ]; then
        echo "Start Hyprland with command Hyprland"
    fi
fi

eval "$(starship init zsh)"
