{
  config,
  lib,
  pkgs,
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
        kitty_mod = "ctrl+shift";

        # Appearance
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

        # Layouts
        enabled_layouts = "tall,splits,stack";

        # Window & Session Behavior
        allow_remote_control = "yes";
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
        # Scrolling
        "alt+u" = "scroll_page_up";
        "alt+d" = "scroll_page_down";
        "alt+shift+k" = "scroll_line_up";
        "alt+shift+j" = "scroll_line_down";

        # Windows
        "alt+enter" = "new_window_with_cwd";
        "alt+q" = "close_window";
        "alt+r" = "start_resizing_window";
        "alt+h" = "neighboring_window left";
        "alt+l" = "neighboring_window right";
        "alt+k" = "neighboring_window up";
        "alt+j" = "neighboring_window down";

        # Tabs
        "kitty_mod+t" = "new_tab_with_cwd";
        "kitty_mod+l" = "next_tab";
        "kitty_mod+h" = "previous_tab";
        "kitty_mod+," = "move_tab_backward";
        "kitty_mod+." = "move_tab_forward";

        # Layouts
        "kitty_mod+m" = "toggle_layout tall";
        "kitty_mod+space" = "swap_with_window";
      };
    };
  };
}
