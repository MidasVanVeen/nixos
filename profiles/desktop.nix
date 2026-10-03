{ config, ... }:
{
  imports = [
    ./headless-user.nix
    ../modules/system/desktop.nix
  ];

  home-manager.users.${config.my.user.name}.imports = [ ../modules/user/desktop.nix ];
}
