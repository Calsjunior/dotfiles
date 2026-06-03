{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    cli.neovim.enable = lib.mkEnableOption "Enable Neovim";
  };

  config = lib.mkIf config.cli.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;

      # Download treesitter languages
      plugins = with pkgs.vimPlugins; [
        nvim-treesitter.withAllGrammars
      ];

      extraPackages = with pkgs; [
        # Treesitter Build tools
        tree-sitter
        gcc
        gnumake

        # Tools required by LazyVim
        ripgrep
        fd
        fzf
        lazygit

        # Language Servers and Formatters
        # Lua
        lua-language-server
        stylua

        # C
        clang-tools

        # Web
        vscode-langservers-extracted
        emmet-language-server
        typescript-language-server
        biome

        # Python
        ruff

        # Nix
        nil
        nixfmt
      ];

      withPython3 = false;
      withRuby = false;
    };

    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim";
  };
}
