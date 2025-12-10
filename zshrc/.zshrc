# =============================================================================
#  ZSH HISTORY
# =============================================================================
HISTFILE="$HOME/.zsh_history"    # Where to save history
HISTSIZE=10000                   # How many lines to keep in memory
SAVEHIST=10000                   # How many lines to save to disk
setopt SHARE_HISTORY             # Share history across terminals immediately
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space

# =============================================================================
#  VIM MODE & CURSOR FIXES
# =============================================================================
bindkey -v                       # Enable Vim Mode
export KEYTIMEOUT=1

# Restore standard keys that Vim mode breaks
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history

# Change cursor shape (Beam in Insert Mode, Block in Normal Mode)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q' # Block cursor
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q' # Beam cursor
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # Default to Insert Mode
    echo -ne "\e[5 q"
}
zle -N zle-line-init

# =============================================================================
#  COMPLETION SETTINGS 
# =============================================================================
# Initialize completion system
autoload -Uz compinit
compinit

# Enable the "Interactive Menu"
zstyle ':completion:*' menu select

# Load menu keymap
zmodload zsh/complist

# Case insensitive completion 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Pretty colors for the completion list
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =============================================================================
#  CUSTOM KEYBINDINGS
# =============================================================================
setopt MENU_COMPLETE
bindkey '^@' menu-complete

# Navigation inside the Menu (Ctrl+N/P)
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history

# Ctrl+Enter and Ctrl+y to accept menu and autosuggestions 
bindkey -M menuselect '^[[13;5u' accept-line
bindkey '^[[13;5u' autosuggest-accept

bindkey -M menuselect '^y' accept-line
bindkey '^y' autosuggest-accept

# =============================================================================
#  EXPORTS
# =============================================================================
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=zen-browser
export TERMINAL=kitty
export PATH="$HOME/.local/bin/:$PATH"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export GTK_THEME=adw-gtk3-dark

# =============================================================================
#  ALIASES
# =============================================================================
# Editor
alias v="nvim"

# Package Management (Pacman/Yay)
alias ip="sudo pacman -S"
alias rp="sudo pacman -Rns"
alias up="sudo pacman -Syu"
alias iy="yay -S"
alias ry="yay -Rns"
alias uy="yay -Syu"

# Search & File Operations
alias f="find . -iname"
alias g="grep --color=auto -R"
alias ls='ls --color=auto'
alias recent-installs='expac --timefmt="%Y-%m-%d %T" "%l\t%n" $(pacman -Qqe) | sort'
alias duh="du -h --max-depth=1"
alias duu="du -sh *"

# Pandoc
md2pdf() {
    pandoc "$1" -o "${1%.*}.pdf" --pdf-engine=tectonic -V geometry:margin=1in
    echo "Converted $1 to ${1%.*}.pdf"
}
# =============================================================================
#  PLUGINS 
# =============================================================================
# 1. Autosuggestions 
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606060'
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# 2. Syntax Highlighting 
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# =============================================================================
#  INITIALIZATION 
# =============================================================================

# Fastfetch 
if [[ $(tty) == *"pts"* ]]; then
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

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

source <(fzf --zsh)
