{
  config,
  omnibin,
  pkgs,
  ...
}:

let
  omnibinPackages = omnibin.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    ../hardware/macbook/hardware-configuration.nix
    ../hardware/macbook/boot.nix
    ../profiles/desktop.nix
    ../modules/secrets.nix
    ../modules/system/comin.nix
    ../services
  ];

  networking.hostName = "m22";
  my.user.name = "midas";

  home-manager.users.${config.my.user.name}.home.packages = [
    omnibinPackages.omnibin
    omnibinPackages.omnibin-shell
  ];

  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ../hardware/macbook/vendorfw;
  hardware.apple.touchBar = {
    enable = true;
    package = pkgs.tiny-dfr;
  };

  system.stateVersion = "26.11";
}
