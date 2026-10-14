{ pkgs, ... }:

let
  kollektif-font = pkgs.runCommand "kollektif-font" {
    src = pkgs.fetchurl {
      url = "https://bnffonts.com/fonts/kollektif.zip";
      hash = "sha256-HrMka1VRN5K4pxf092lKdFIJecjYf1SJ33uWTmc8lks=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p "$out/share/fonts/truetype"
    unzip -j "$src" '*.ttf' -d "$out/share/fonts/truetype"
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    sops
    ssh-to-age
    vim
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      geist-font
      kollektif-font
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  };

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  services.dbus.enable = true;
  services.flatpak.enable = true;
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      grim
      slurp
      sway-contrib.grimshot
      swayidle
      swaylock
      wl-clipboard
    ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };

  services.gvfs.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
