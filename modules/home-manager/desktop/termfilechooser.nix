# To enable termfilechooser for a filemanager, in home-manager module, do:
# Example Yazi:
# desktop.termfilechooser = {
#   enable = true;
#   wrapperCmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
#   terminalCmd = config.cli.yazi.terminalCmd;
# };
# and enable in configuration.nix:
# portals.xdg-desktop-portal.termfilechooser.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.desktop.termfilechooser = {
    enable = lib.mkEnableOption "Terminal File Chooser Portal";

    wrapperCmd = lib.mkOption {
      type = lib.types.str;
      description = "The path to the file manager wrapper script (e.g. yazi-wrapper.sh)";
    };

    terminalCmd = lib.mkOption {
      type = lib.types.str;
      description = "The terminal execution command (e.g. kitty)";
    };
  };

  config = lib.mkIf config.desktop.termfilechooser.enable {
    # Provide the package to the user-level D-Bus
    home.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

    xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
      force = true;
      text = ''
        [filechooser]
        cmd=${config.desktop.termfilechooser.wrapperCmd}
        default_dir=$HOME/Downloads
        env=TERMCMD=${config.desktop.termfilechooser.terminalCmd} --class termfilechooser -e
        env=PATH="$PATH:/run/current-system/${config.home.profileDirectory}/bin"
        open_mode=suggested
        save_mode=last
      '';
    };
  };
}
