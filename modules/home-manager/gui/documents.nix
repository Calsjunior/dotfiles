{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    gui.documents.enable = lib.mkEnableOption "Enable Document Viewers and Editors";
  };

  config = lib.mkIf config.gui.documents.enable {

    home.packages = with pkgs; [
      wordcraft
      gridcraft
    ];

    programs.zathura = {
      enable = true;
      options = {
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        selection-clipboard = "clipboard";
      };

      extraConfig = ''
        include noctaliarc
      '';
    };

    xdg.mimeApps = {
      defaultApplications = {
        # Make Zathura the default for all PDFs
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      }
      // lib.genAttrs [
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" # .docx
        "application/vnd.oasis.opendocument.text" # .odt
        "application/msword" # .doc
        "application/rtf"
      ] (_: [ "ai.storyteller.wordcraft.desktop" ])
      // lib.genAttrs [
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" # .xlsx
        "application/vnd.ms-excel" # .xls
      ] (_: [ "ai.storyteller.gridcraft.desktop" ]);
    };
  };
}
