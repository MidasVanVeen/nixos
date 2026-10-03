{ config, ... }:
let
  username = config.my.user.name;
in
{
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_rsa" ];
  sops.secrets.bashrc-secrets = {
    sopsFile = ../secrets/bashrc-secrets.env;
    format = "dotenv";
    owner = username;
    mode = "0400";
  };
}
