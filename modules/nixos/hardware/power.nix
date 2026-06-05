{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    sys.hardware.power.enable = lib.mkEnableOption "Enable laptop power management";
  };

  config = lib.mkIf config.sys.hardware.power.enable {

    services.power-profiles-daemon.enable = false;

    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };

    powerManagement.powertop.enable = true;

  };
}
