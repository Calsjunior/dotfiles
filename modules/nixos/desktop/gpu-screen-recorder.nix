{
  config,
  lib,
  ...
}:
{
  options = {
    desktop.gpu-screen-recorder.enable = lib.mkEnableOption "Enable GPU Screen Recorder";
  };

  config = lib.mkIf config.desktop.gpu-screen-recorder.enable {
    programs.gpu-screen-recorder.enable = true;
  };
}
