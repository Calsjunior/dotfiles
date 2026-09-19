{
  pkgs,
  config,
  lib,
  inputs,
  dotfilesPath,
  ...
}:
{
  options = {
    cli.neovim.enable = lib.mkEnableOption "Enable Neovim";
  };

  config = lib.mkIf config.cli.neovim.enable {
    programs.neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
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

        # Tools required in configuration
        ripgrep
        (symlinkJoin {
          name = "lazygit";
          paths = [ lazygit ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/lazygit \
              --prefix LG_CONFIG_FILE "," "${
                writeText "config.yml" /* yaml */ ''
                  gui:
                    nerdFontsVersion: '3'
                    showFileTree: false
                    showCommandLog: false
                    skipRewordInEditorWarning: true
                    authorColors:
                      "${config.programs.git.settings.user.name}": 'cyan'
                      '*': 'magenta'
                  git:
                    autoFetch: false
                    overrideGpg: true
                    branchLogCmd: 'git log --graph --color=always --abbrev-commit --decorate --date=iso --pretty=medium {{branchName}} --'
                    allBranchesLogCmds:
                      - 'git log --all --graph --color=always --abbrev-commit --decorate --date=iso --pretty=medium'
                  update:
                    method: 'never'
                  notARepository: 'quit'
                  promptToReturnFromSubprocess: false
                  keybinding:
                    files:
                      commitChanges: 'C'
                      commitChangesWithEditor: 'c'
                      toggleStagedAll: '<c-8>'
                ''
              }"
          '';
        })

        # Language Servers and Formatters
        # Lua
        lua-language-server
        stylua

        # C
        clang-tools

        # Web
        vscode-langservers-extracted
        css-variables-language-server
        emmet-language-server
        vtsls
        biome

        # Nix
        nixd
        nixfmt

        # Typst
        tinymist

        # Grammar lsp
        harper
      ];

      withPython3 = false;
      withRuby = false;
    };

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";

    home.sessionVariables = {
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };
}
