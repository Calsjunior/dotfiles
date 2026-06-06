{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  options.gui.browser.zen.enable = lib.mkEnableOption "Enable Zen Browser";

  config = lib.mkIf config.gui.browser.zen.enable {

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;

        ExtensionSettings = {
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # Dark Reader
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
          # SponsorBlock
          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
          # Return YouTube Dislike
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };

      profiles.default = {
        isDefault = true;

        settings = {
          # Core Browser & Privacy
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "signon.rememberSignons" = false; # Disable native password manager
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "media.hardware-video-decoding.force-enabled" = true;

          # Move URL bar to the top toolbar
          "zen.view.use-single-toolbar" = false;

          # Hide window controls
          "browser.tabs.inTitlebar" = 0;

          # Force Dark Theme everywhere
          "ui.systemUsesDarkTheme" = 1;
          "browser.in-content.dark-mode" = true;

          # Tab Suspension (30 mins)
          "browser.tabs.unloadOnLowMemory" = true;
          "browser.low_commit_space_threshold_percent" = 100;
          "browser.tabs.min_inactive_duration_before_unload" = 1800000;

          # Developer Tools Setup
          "devtools.chrome.enabled" = true;
          "devtools.command-button-screenshot.enabled" = true;
          "devtools.gridinspector.showGridAreas" = true;
          "devtools.responsive.touchSimulation.enabled" = true;
          "devtools.toolbox.selectedTool" = "webconsole";

          # Cleaned URL Bar
          "mod.cleanedurlbar.customcolor" = "hsl(0 0 10)";
          "mod.cleanedurlbar.customselectcolor" = "rgba(80, 80, 250, 0.75)";
          "mod.cleanedurlbar.customselectfontcolor" = "rgba(255,255,255,1)";
          "mod.cleanedurlbar.customtransparency" = "0%";

          # Better Ctrl Tab
          "psu.better_ctrltab.background" = "light-dark(rgba(144, 144, 144, 0.94), rgba(22, 22, 22, 0.92))";
          "psu.better_ctrltab.padding" = "16px";
          "psu.better_ctrltab.preview_border_color" =
            "light-dark(rgba(255, 255, 255, 0.1), rgba(1, 1, 1, 0.1))";
          "psu.better_ctrltab.preview_border_width" = "1px";
          "psu.better_ctrltab.preview_favicon_outdent" = "12px";
          "psu.better_ctrltab.preview_favicon_size" = "36px";
          "psu.better_ctrltab.preview_focus_background" =
            "light-dark(rgba(77, 77, 77, 0.8), rgba(204, 204, 204, 0.33))";
          "psu.better_ctrltab.preview_font_size" = "13px";
          "psu.better_ctrltab.preview_letter_spacing" = "0px";
          "psu.better_ctrltab.roundness" = "28px";
          "psu.better_ctrltab.shadow_size" = "18px";
          "psu.better_ctrltab.zoom" = "0.8";

          # Better Find Bar
          "theme-better_find_bar-enable_custom_background" = false;
          "theme.better_find_bar.custom_background" = "";
          "theme.better_find_bar.hide_find_status" = false;
          "theme.better_find_bar.hide_found_matches" = false;
          "theme.better_find_bar.hide_highlight" = "not_hide";
          "theme.better_find_bar.hide_match_case" = "not_hide";
          "theme.better_find_bar.hide_match_diacritics" = "not_hide";
          "theme.better_find_bar.hide_whole_words" = "not_hide";
          "theme.better_find_bar.horizontal_position" = "default";
          "theme.better_find_bar.instant_animations" = false;
          "theme.better_find_bar.textbox_width" = "800";
          "theme.better_find_bar.transparent_background" = false;
          "theme.better_find_bar.vertical_position" = "top";

          # Custom Statusbar
          "theme.customstatusbar.border_thickness" = "2px";
          "theme.customstatusbar.color_background" = "var(--zen-colors-tertiary)";
          "theme.customstatusbar.color_border" = "var(--zen-colors-border)";
          "theme.customstatusbar.margin" = "3px";
          "theme.customstatusbar.radius" = "1000px";
          "theme.customstatusbar.text_color" = "var(--lwt-text-color)";

          # Bookmark Toolbar Tweaks
          "uc.bookmarks.center-toolbar" = true;
          "uc.bookmarks.expand-on-hover" = false;
          "uc.bookmarks.expand-on-search" = false;
          "uc.bookmarks.hide-favicons" = false;
          "uc.bookmarks.hide-folder-icons" = true;
          "uc.bookmarks.hide-name" = true;
          "uc.bookmarks.position-toolbar" = "left";
          "uc.bookmarks.transparent" = false;

          # Essentials & Pins
          "mod.superpins.essentials.grid-count" = "1";
          "mod.superpins.pins.active-bg" = "";
          "mod.superpins.pins.grid-count" = "1";
          "uc.essentials.auto-grow" = false;
          "uc.essentials.box-like-corners" = false;
          "uc.essentials.color-scheme" = "";
          "uc.essentials.gap" = "Normal";
          "uc.essentials.position" = "bottom";
          "uc.essentials.same-height" = false;
          "uc.essentials.transition-speed" = "100ms";
          "uc.essentials.width" = "Normal";
          "uc.pins.active-bg" = false;
          "uc.pins.auto-grow" = false;
          "uc.pins.bg" = false;
          "uc.pins.essentials-layout" = false;
          "uc.pins.legacy-layout" = false;
          "uc.pins.transition-speed" = "100ms";
          "uc.superpins.border" = "pins";
          "uc.superpins.essentials-below-indicator" = false;

          # Zen Context Menu & UI Fixes
          "mod.extension.viewgrid" = true;
          "mod.lean.hide-zoom" = true;
          "mod.lean.top-workspace" = true;
          "uc.fixcontext.applyzenaccent" = false;
          "uc.fixcontext.applyzengradient" = true;
          "uc.fixcontext.ergonomicsfortabs" = true;
          "uc.fixcontext.restoreicons" = false;
          "uc.hidecontext.askchatbot" = true;
          "uc.hidecontext.audiovideo" = true;
          "uc.hidecontext.bookmark" = true;
          "uc.hidecontext.copylink" = true;
          "uc.hidecontext.icons" = true;
          "uc.hidecontext.image" = true;
          "uc.hidecontext.newcontainer" = true;
          "uc.hidecontext.printselection" = true;
          "uc.hidecontext.reloadtab" = true;
          "uc.hidecontext.searchinpriv" = true;
          "uc.hidecontext.selectalltabs" = true;
          "uc.hidecontext.selectalltext" = true;
          "uc.hidecontext.sendtodevice" = true;
          "uc.hidecontext.separators" = true;
          "uc.pywalzen.darkness" = "default";
          "uc.remove-sidebar-scrollbar" = true;
          "uc.tabs.dim-type" = "both";
          "uc.tabs.show-separator" = "pinned-shown";
          "uc.tabs.strikethrough-on-pending" = false;
          "uc.workspace.current.icon.size" = "";
        };

        mods = [
          "72f8f48d-86b9-4487-acea-eb4977b18f21" # Better ctrl tabs
          "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better far bars
          "ea1a5ace-f698-4b45-ab88-6e8bd3a563f0" # Bookmark Toolbar Tweaks
          "a5f6a231-e3c8-4ce8-8a8e-3e93efd6adec" # Cleaned URL bars
          "32aca67a-ffdd-49e7-95c7-1821793610ca" # Custom Statusbar
          "6c122084-c4ec-4c9e-8cc5-3d87c3a089cb" # NavBar Margin
          "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
          "81fcd6b3-f014-4796-988f-6c3cb3874db8" # Zen Context Menu
        ];
      };
    };

    home.sessionVariables = {
      BROWSER = "zen-beta";
    };
  };
}
