zmodload zsh/zprof
# =============================================================================
#  ZSH HISTORY
# =============================================================================
HISTFILE="$HOME/.zsh_history"    # Where to save history
HISTSIZE=100000                  # How many lines to keep in memory
SAVEHIST=100000                  # How many lines to save to disk
setopt SHARE_HISTORY             # Share history across terminals immediately
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries to the history file
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
if [[ -z ~/.zcompdump(#qN.mh+24) ]]; then
    compinit -d ~/.zcompdump
else
    compinit -C -d ~/.zcompdump
fi

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
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=zen-browser
export TERMINAL=kitty
export PATH="$HOME/.local/bin:$PATH"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export GTK_THEME=adw-gtk3-dark
export MANPAGER='nvim +Man!'

export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git --exclude node_modules --exclude .cache --exclude Trash"
export FZF_DEFAULT_OPTS="--scheme=path --tiebreak=end,length --preview 'bat --color=always {}'"

# =============================================================================
#  ALIASES
# =============================================================================
# Editor
alias v="nvim"

# Package Management (Pacman/Yay)
# alias ip="sudo pacman -S"
# alias rp="sudo pacman -Rns"
# alias up="sudo pacman -Syu"
# alias iy="yay -S"
# alias ry="yay -Rns"
# alias uy="yay -Syu"

# Search & File Operations
alias f="find . -iname"
alias g="grep --color=auto -R"
alias ls='eza --icons -H --group-directories-first --git -1'
alias recent-installs='expac --timefmt="%Y-%m-%d %T" "%l\t%n" $(pacman -Qqe) | sort'

# Pandoc
md2pdf() {
    pandoc "$1" -f markdown -o "${1%.*}.pdf" --pdf-engine=tectonic -V geometry:margin=1in
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
if [ -f /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]; then
    source /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi

# =============================================================================
#  INITIALIZATION 
# =============================================================================

# Lazy Load Node Version Manager
declare -a nvm_triggers=(node npm nvm pnpm yarn)
for cmd in $nvm_triggers; do
    eval "$cmd() { unset -f $nvm_triggers; source /usr/share/nvm/init-nvm.sh; $cmd \"\$@\"; }"
done

# Tools
eval "$(zoxide init --cmd cd zsh)"
source <(fzf --zsh)

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

eval "$(starship init zsh)"
zprof
