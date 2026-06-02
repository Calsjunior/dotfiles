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
    ];
  };
}
