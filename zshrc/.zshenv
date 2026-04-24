# =============================================================================
#  EXPORTS
# =============================================================================
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=zen-browser
export TERMINAL=kitty
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export GTK_THEME=adw-gtk3-dark
export MANPAGER='nvim +Man!'
export FZF_DEFAULT_COMMAND="fd --hidden --exclude .git --exclude node_modules --exclude .cache --exclude .local"
export FZF_CTRL_T_COMMAND="fd --type f --hidden --exclude .git --exclude node_modules --exclude .cache --exclude .local"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git --exclude node_modules --exclude .cache --exclude .local"
export FZF_DEFAULT_OPTS="--scheme=path --tiebreak=end,length \
--preview '
if [[ -d {} ]]; then
    eza --tree --level=2 --color=always --icons=always --git {}
else
  bat --color=always {}
fi'
"

