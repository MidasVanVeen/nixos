{ config, ... }:
{
  imports = [
    ./headless.nix
    ../modules/user/account.nix
  ];

  home-manager.users.${config.my.user.name} = {
    imports = [ ../modules/user/neovim.nix ];
    home.sessionVariables.EDITOR = "nvim";
  };
}
