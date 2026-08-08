{
  config,
  lib,
  ...
}:
{
  options = {
    sys.media.enable = lib.mkEnableOption "Enable GPU Screen Recorder";
  };

  config = lib.mkIf config.sys.media.enable {
    programs.gpu-screen-recorder.enable = true;
  };
}
