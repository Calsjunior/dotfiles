{
  config,
  lib,
  osConfig,
  ...
}:
{
  options.gui.kitty = {
    enable = lib.mkEnableOption "Enable Kitty Terminal";

    fontName = lib.mkOption {
      type = lib.types.str;
      default = osConfig.sys.fonts.defaultMonospace;
      description = "The font family for Kitty. Defaults to the system monospace font.";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "The font size for Kitty.";
    };
  };

  config = lib.mkIf config.gui.kitty.enable {
    programs.kitty = {
      enable = true;

      font = {
        name = config.gui.kitty.fontName;
        size = config.gui.kitty.fontSize;
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
        enabled_layouts = "splits,tall,stack";

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
        "alt+w>d" = "close_window";

        "alt+w>v" = "launch --location=vsplit --cwd=current";
        "alt+w>s" = "launch --location=hsplit --cwd=current";

        # Tab Management
        "alt+enter" = "new_tab_with_cwd";
        "alt+shift+l" = "next_tab";
        "alt+shift+h" = "previous_tab";
        "alt+b>d" = "close_tab";

        "alt+b>r" = "set_tab_title";
        "alt+b>l" = "move_tab_forward";
        "alt+b>h" = "move_tab_backward";

        # Layouts
        "alt+w>m" = "toggle_layout tall";
        "alt+w>z" = "toggle_layout stack"; # Zoom current window to full screen

        # Scrolling & Pager
        "alt+u" = "scroll_page_up";
        "alt+d" = "scroll_page_down";

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

      # Smart-Splits Integration
      extraConfig = ''
        # Clear Screen
        map ctrl+shift+l send_text all \x0c

        # Movement
        map ctrl+j neighboring_window down
        map ctrl+k neighboring_window up
        map ctrl+h neighboring_window left
        map ctrl+l neighboring_window right

        map --when-focus-on var:IS_NVIM ctrl+j
        map --when-focus-on var:IS_NVIM ctrl+k
        map --when-focus-on var:IS_NVIM ctrl+h
        map --when-focus-on var:IS_NVIM ctrl+l

        # Resizing
        map alt+j kitten ~/.local/share/nvim/lazy/smart-splits.nvim/kitty/relative_resize.py down  3
        map alt+k kitten ~/.local/share/nvim/lazy/smart-splits.nvim/kitty/relative_resize.py up    3
        map alt+h kitten ~/.local/share/nvim/lazy/smart-splits.nvim/kitty/relative_resize.py left  3
        map alt+l kitten ~/.local/share/nvim/lazy/smart-splits.nvim/kitty/relative_resize.py right 3

        map --when-focus-on var:IS_NVIM alt+j
        map --when-focus-on var:IS_NVIM alt+k
        map --when-focus-on var:IS_NVIM alt+h
        map --when-focus-on var:IS_NVIM alt+l
      '';
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
