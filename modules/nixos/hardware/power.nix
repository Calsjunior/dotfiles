{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sys.hardware.power;
in
{
  options.sys.hardware.power = {
    enable = lib.mkEnableOption "Enable laptop power management";

    batteryMaxFreq = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Maximum CPU frequency in kHz while on battery. Leaves uncapped if null.";
    };

    chargerMaxFreq = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Maximum CPU frequency in kHz while on charger. Leaves uncapped if null.";
    };
  };

  config = lib.mkIf cfg.enable {

    services.power-profiles-daemon.enable = false;
    services.upower.enable = true;

    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        turbo = "never";
      }
      // lib.optionalAttrs (cfg.batteryMaxFreq != null) {
        scaling_max_freq = cfg.batteryMaxFreq;
      };

      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        turbo = "auto";
      }
      // lib.optionalAttrs (cfg.chargerMaxFreq != null) {
        scaling_max_freq = cfg.chargerMaxFreq;
      };
    };

    powerManagement.powertop.enable = true;
  };
}
