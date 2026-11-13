{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.sys.dm.ly;
  session = config.services.displayManager.defaultSession;
in
{
  options.sys.dm.ly = {
    enable = lib.mkEnableOption "ly display manager";
    autologin = lib.mkEnableOption "automatic login into the host's window manager";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !cfg.autologin || session != null;
            message = "sys.dm.ly.autologin needs a window manager enabled (e.g. wm.hyprland.enable).";
          }
        ];

        services.displayManager.ly = {
          enable = true;
          settings = {
            session_log = null;
            auto_login_session = if cfg.autologin then session else null;
            auto_login_user = if cfg.autologin then user else null;
          };
        };
      }

      (lib.mkIf cfg.autologin {
        security.pam.services.ly-autologin.text = ''
          auth     required pam_permit.so
          account  include  login
          password substack login
          session  include  login
        '';
      })
    ]
  );
}
