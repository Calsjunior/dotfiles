{
  pkgs,
  config,
  lib,
  dotfilesPath,
  ...
}:
{
  options.cli.scripts.enable = lib.mkEnableOption "Enable custom scripts";

  config = lib.mkIf config.cli.scripts.enable {
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "mkdev";
        text = ''
          template="''${1:-web}"
          template_dir="${dotfilesPath}/templates/$template"

          if [ ! -d "$template_dir" ]; then
            echo "Error: Template '$template' does not exist in ${dotfilesPath}/templates/" >&2
            exit 1
          fi

          if [ ! -d .git ]; then
            git init
          fi

          nix flake init --template "${dotfilesPath}#$template"
          git add flake.nix .envrc
          nix flake lock
          git add flake.lock
          direnv allow

          git commit -m "chore(flake): initialize $template nix environment"
        '';
      })

      (writeShellApplication {
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

      (writeShellApplication {
        name = "md2pdf";
        runtimeInputs = with pkgs; [
          pandoc
          typst
        ];
        text = ''
          if [ -z "''${1:-}" ]; then
            echo "Usage: md2pdf <file.md>"
            exit 1
          fi

          pandoc "$1" -f markdown -o "''${1%.*}.pdf" --pdf-engine=typst -V mainfont="New Computer Modern"

          echo "Converted $1 to ''${1%.*}.pdf"
        '';
      })
    ];
  };
}
