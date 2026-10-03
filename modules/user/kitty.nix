{ ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono Normal NF";
      size = 11;
    };
    settings = {
      background = "#000000";
      foreground = "#ffffff";
      cursor = "#ffffff";
      cursor_text_color = "#000000";
      selection_background = "#ffffff";
      selection_foreground = "#000000";
      url_color = "#ffffff";
      tab_bar_background = "#000000";
      active_tab_background = "#ffffff";
      active_tab_foreground = "#000000";
      inactive_tab_background = "#111111";
      inactive_tab_foreground = "#bbbbbb";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };
}
