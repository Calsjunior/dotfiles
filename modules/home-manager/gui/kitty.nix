{
  config,
  lib,
  ...
}:
{
  options = {
    gui.kitty.enable = lib.mkEnableOption "Enable Kitty Terminal";
  };

  config = lib.mkIf config.gui.kitty.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };
      themeFile = "GruvboxMaterialDarkMedium";

      settings = {
        clear_all_shortcuts = "yes";
        map_timeout = "1.5";

        # Appearance & Layouts
        cursor_shape = "block";
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.4";
        shell_integration = "no-cursor";
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = " {index}: {title[title.rfind('/')+1:]} ";
        touch_scroll_multiplier = 8;
        window_padding_width = "0 5";
        enabled_layouts = "tall,splits,stack";

        # Window Behavior
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/mykitty";
        remember_window_size = "yes";
        initial_window_width = 1000;
        initial_window_height = 650;
        close_on_child_death = "no";
        confirm_os_window_close = 0;

        # Borders
        active_border_color = "#7a7a7a";
        inactive_border_color = "#504945";
        window_border_width = "1pt";
        draw_minimal_borders = "yes";
      };

      keybindings = {
        # Window Management
        "alt+w>c" = "new_window_with_cwd";
        "alt+w>q" = "close_window";

        "alt+w>v" = "launch --location=vsplit --cwd=current";
        "alt+w>s" = "launch --location=hsplit --cwd=current";

        "alt+w>h" = "neighboring_window left";
        "alt+w>l" = "neighboring_window right";
        "alt+w>k" = "neighboring_window up";
        "alt+w>j" = "neighboring_window down";

        # Tab Management
        "alt+enter" = "new_tab_with_cwd";
        "alt+shift+l" = "next_tab";
        "alt+shift+h" = "previous_tab";
        "alt+b>d" = "close_tab";

        # Layouts
        "alt+w>m" = "toggle_layout tall";
        "alt+w>z" = "toggle_layout stack"; # Zoom current window to full screen

        # Scrolling
        "alt+u" = "scroll_page_up";
        "alt+d" = "scroll_page_down";
        "alt+k" = "scroll_line_up";
        "alt+j" = "scroll_line_down";

        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";

        # Font size
        "ctrl+equal" = "change_font_size all +1.0";
        "ctrl+minus" = "change_font_size all -1.0";
        "ctrl+0" = "change_font_size all 0";

        # Copy and paste
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
      };
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
