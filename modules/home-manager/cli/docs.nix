{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    cli.docs.enable = lib.mkEnableOption "Enable document processing tools";
  };

  config = lib.mkIf config.cli.docs.enable {
    home.packages = with pkgs; [
      pandoc
      tectonic

      (pkgs.writeShellScriptBin "md2pdf" ''
        if [ -z "$1" ]; then
          echo "Usage: md2pdf <file.md>"
          exit 1
        fi
        ${pkgs.pandoc}/bin/pandoc "$1" -f markdown -o "''${1%.*}.pdf" --pdf-engine=${pkgs.tectonic}/bin/tectonic -V geometry:margin=1in
        echo "Converted $1 to ''${1%.*}.pdf"
      '')
    ];
  };
}
