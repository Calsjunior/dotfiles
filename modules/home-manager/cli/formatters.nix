{
  config,
  lib,
  ...
}:
{
  options = {
    cli.formatters.enable = lib.mkEnableOption "Enable formatters to $HOME";
  };

  config = lib.mkIf config.cli.formatters.enable {
    home.file = {
      ".clang-format".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/formatters/.clang-format";

      "biome.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/formatters/biome.json";
    };
  };
}
