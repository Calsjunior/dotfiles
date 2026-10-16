{
  config,
  lib,
  user,
  ...
}:
{
  options.sys.gaming.enable = lib.mkEnableOption "Enable system configs for gaming (Gamemode, SOCD)";

  config = lib.mkIf config.sys.gaming.enable {
    programs.gamemode.enable = true;
    users.users.${user}.extraGroups = [ "gamemode" ];

    # Allow user systemd scopes to manage CPU cores (allow systemd-run --user --scope -p AllowedCPUs=... to work)
    systemd.services."user@".serviceConfig.Delegate = [
      "cpu"
      "cpuset"
    ];

    services.kanata = {
      enable = true;
      keyboards = {
        internalKeyboard = {
          extraDefCfg = ''
            process-unmapped-keys yes
          '';
          config = ''
            (defsrc)

            (defvirtualkeys
              out-a a
              out-d d
              a-held nop0
              d-held nop1

              a-rel (multi
                      (on-press release-vkey a-held)
                      (on-press release-vkey out-a)
                      (switch ((input virtual d-held)) (on-press press-vkey out-d) break () XX break))
              d-rel (multi
                      (on-press release-vkey d-held)
                      (on-press release-vkey out-d)
                      (switch ((input virtual a-held)) (on-press press-vkey out-a) break () XX break))
            )

            (deflayermap (base)
              a (multi
                  (on-press press-vkey a-held)
                  (on-press release-vkey out-d)
                  (on-press press-vkey out-a)
                  (on-release tap-vkey a-rel))
              d (multi
                  (on-press press-vkey d-held)
                  (on-press release-vkey out-a)
                  (on-press press-vkey out-d)
                  (on-release tap-vkey d-rel))
            )
          '';
        };
      };
    };

    # Cache settings need to be set as environment variables for them to work.
    # However, games launched via lutris still need to read from lutris's
    # config, so the __GL_SHADER_DISK_CACHE_PATH below may or may not work.
    # https://github.com/ValveSoftware/steam-for-linux/issues/11392#issue-2616538419#1
    environment.sessionVariables = lib.mkIf config.sys.hardware.nvidia.enable {
      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      __GL_SHADER_DISK_CACHE_PATH = "\${HOME}/.cache/nvidia";
    };
  };
}
