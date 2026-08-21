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
let
  portalWrapper = pkgs.writeShellScript "termfilechooser-wrapper" ''
    export PATH="${config.home.profileDirectory}/bin:/run/current-system/sw/bin:$PATH"
    if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
      source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    fi

    exec ${config.desktop.termfilechooser.wrapperCmd} "$@"
  '';
in
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
        cmd=${portalWrapper}
        default_dir=${config.home.homeDirectory}/Downloads
        env=TERMCMD=${config.desktop.termfilechooser.terminalCmd} --class termfilechooser -e
        open_mode=suggested
        save_mode=last
      '';
    };
  };
}
