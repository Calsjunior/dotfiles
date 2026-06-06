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
      onlyoffice-desktopeditors
    ];

    programs.zathura = {
      enable = true;
      options = {
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        selection-clipboard = "clipboard";
        recolor = true;
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Make Zathura the default for all PDFs
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];

        # Make OnlyOffice the default for Office documents
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .docx
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .xlsx
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "onlyoffice-desktopeditors.desktop"
        ]; # .pptx
      };
    };

  };
}
