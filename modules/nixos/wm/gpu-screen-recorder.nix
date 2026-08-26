{
  config,
  lib,
  ...
}:
{
  options = {
    wm.gpu-screen-recorder.enable = lib.mkEnableOption "Enable GPU Screen Recorder";
  };

  config = lib.mkIf config.wm.gpu-screen-recorder.enable {
    programs.gpu-screen-recorder.enable = true;
  };
}
