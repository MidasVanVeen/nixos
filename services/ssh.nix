{ config, ... }:
let
  user = config.my.user.name or "root";
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpefuRpvepWVnJYlVOelftRZD5rzRQS/vyoUKpnp3WM midasvanveen.email@gmail.com";
in
{
  users.users.${user}.openssh.authorizedKeys.keys = [ key ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ config.my.services.ports.ssh ];
    settings = {
      PermitRootLogin = if user == "root" then "prohibit-password" else "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
