{ config, lib, ... }:
let
  username = config.my.user.name;
in
{
  options.my.user.name = lib.mkOption {
    type = lib.types.str;
    description = "Username of the host's normal account.";
  };

  config = {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]
        ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
        ++ lib.optionals config.programs.sway.enable [ "video" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      users.${username} = {
        imports = [ ./bash.nix ];
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.stateVersion = config.system.stateVersion;
        xdg.enable = true;
        programs.home-manager.enable = true;
      };
    };
  };
}
