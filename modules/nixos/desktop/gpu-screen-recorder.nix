{
  config,
  lib,
  ...
}:
{
  options.desktop.gpu-screen-recorder.enable = lib.mkEnableOption "gpu screen recorder";

  config = lib.mkIf config.desktop.gpu-screen-recorder.enable {
    programs.gpu-screen-recorder.enable = true;
  };
}
