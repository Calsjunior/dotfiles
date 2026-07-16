{
  config,
  lib,
  ...
}:
{
  options = {
    cli.formatters.enable = lib.mkEnableOption "Enable formatters to $HOME and $XDG_CONFIG_HOME";
  };

  config = lib.mkIf config.cli.formatters.enable {
    home.file = {
      ".clang-format".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/formatters/.clang-format";

      ".config/biome/biome.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/formatters/biome.json";
    };
  };
}
