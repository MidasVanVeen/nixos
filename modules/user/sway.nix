{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    wofi
    polkit_gnome
  ];

  xdg.configFile = {
    "sway/config".source = ../../dotfiles/sway.conf;
    "waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
    "waybar/style.css".source = ../../dotfiles/waybar/style.css;
    "wofi/style.css".source = ../../dotfiles/wofi/style.css;
  };

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "PolicyKit authentication agent";
      PartOf = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.mako = {
    enable = true;
    settings = {
      background-color = "#000000";
      border-color = "#ffffff";
      border-radius = 0;
      border-size = 1;
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 10";
      text-color = "#ffffff";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      inside-color = "000000ff";
      inside-clear-color = "000000ff";
      inside-ver-color = "000000ff";
      inside-wrong-color = "000000ff";
      key-hl-color = "ffffffff";
      ring-color = "ffffffff";
      ring-clear-color = "ffffffff";
      ring-ver-color = "ffffffff";
      ring-wrong-color = "ffffffff";
      text-color = "ffffffff";
    };
  };
}
