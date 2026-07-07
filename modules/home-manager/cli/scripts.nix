{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.cli.scripts.enable = lib.mkEnableOption "Enable custom scripts";

  config = lib.mkIf config.cli.scripts.enable {
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "mkdev";
        text = ''
          TEMPLATE="''${1:-web}"
          TEMPLATE_DIR="$HOME/dotfiles/templates/$TEMPLATE"

          if [ ! -d "$TEMPLATE_DIR" ]; then
            echo "Error: Template '$TEMPLATE' does not exist in $HOME/dotfiles/templates/" >&2
            exit 1
          fi

          if [ ! -d .git ]; then
            git init
          fi

          nix flake init --template "$HOME/dotfiles#$TEMPLATE"
          git add flake.nix .envrc
          nix flake lock
          git add flake.lock
          direnv allow

          git commit -m "chore(flake): initialize $TEMPLATE nix environment"
        '';
      })

      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        text = ''
          ${builtins.replaceStrings [ "ctrl-n" "ctrl-p" ] [ "alt-n" "alt-p" ] (
            builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh"
          )}
        '';
      })
    ];
  };
}
