{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./kitty.nix
    ./appearance.nix
    ./sway.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    libnotify
    maple-mono.Normal-NF
    nautilus
    networkmanagerapplet
    pavucontrol
    playerctl
    wl-clipboard
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "adw-gtk3-dark";
    SOPS_AGE_KEY_CMD = "${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i ${config.home.homeDirectory}/.ssh/id_rsa";
  };

  programs.firefox.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "application/x-gnome-saved-search" = [ "org.gnome.Nautilus.desktop" ];
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
