# Zsh Configuration

My core Zsh environment, split across `.zshrc` (interactive
shell) and `.zshenv` (environment variables and paths).
The goal of this config is to get instant prompt startup, Vi-mode
behavior, and clean fuzzy finding.

## Design Decisions

- **Plugin Loading (`zinit`)**: Heavy plugins (autosuggestions, syntax
  highlighting, zoxide) are loaded asynchronously (`wait"1"`) after the
  prompt renders so the terminal can start up instantly.
- **The FZF / Yazi Split**:
  - `FZF_CTRL_T_COMMAND` uses `--type f` so the terminal shortcut
    doesn't accidentally pass directories to nvim.
  - `FZF_ALT_C_COMMAND` uses `--type d` because it's only used for
    `cd`.

## Keybindings

- **Vi-Mode:** Normal vi/vim/nvim keybinds
- **fzf Integration:**
  - `Ctrl+R`: Fuzzy search terminal history.
  - `Ctrl+T`: Fuzzy search files (pastes path at cursor).
  - `Alt+C`: Fuzzy search directories and instantly `cd` into them.

## Dependencies

### System Packages

- **Core**: `zsh`, `zinit`
- **Prompt**: `fastfetch`, `starship`
- **Navigation**:
  - `fzf`: Fuzzy Finder.
  - `fd`: Replaces `find`, sorta.
  - `zoxide`: Replaces `cd`.
- **CLI Utilities**:
  - `eza`: Replaces `ls` (aliased to ls).
  - `bat`: Syntax highlighting for `fzf`'s preview pane.
  - `expac`: Required for the custom `recent-installs` alias.
- **Development**:
  - `mise`: Manage language environment (Node, Python, etc.).
  - `bob`: Neovim version Manager (Targeted by `PATH`, `EDITOR`, `VISUAL`,
    and `MANPAGER`)
  - `pandoc-cli` & `tectonic`: Required for the custom `md2pdf` conversion
    function.
- **Exports Targets**: `kitty` (TERMINAL), `zen-browser-bin` (BROWSER)

### Zsh Plugins

All plugins are managed by `zinit`
- `zsh-users/zsh-autosuggestions`: Inline auto-suggestions based on terminal history.
- `zdharma-continuum/fast-syntax-highlighting`: Syntax highlighting for commands.
- `zsh-users/zsh-completions`: Expanded tab-completion definitions for
  tools like `node`.
- `romkatv/zsh-defer`: Required to load `zoxide` and `mise` asynchronously
  to minimize startup time.
