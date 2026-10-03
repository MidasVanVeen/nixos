{ config, ... }:
let
  inherit (config.my.services) ports domains urls;
  domain = domains.forgejo;
  rootURL = urls.forgejo or "https://${domain}/";
in
{
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/forgejo 0750 1000 1000 -"
  ];

  environment.etc."containers/systemd/forgejo.container".text = ''
    [Unit]
    Description=Forgejo Git service

    [Container]
    Image=codeberg.org/forgejo/forgejo:16.0.5
    Pull=missing
    ContainerName=forgejo
    PublishPort=127.0.0.1:${toString ports.forgejo}:3000
    PublishPort=${toString ports.forgejoSsh}:22
    Volume=/var/lib/forgejo:/data:Z
    Environment=USER_UID=1000
    Environment=USER_GID=1000
    Environment=FORGEJO__server__DOMAIN=${domain}
    Environment=FORGEJO__server__ROOT_URL=${rootURL}
    Environment=FORGEJO__server__HTTP_PORT=3000
    Environment=FORGEJO__server__SSH_DOMAIN=${domain}
    Environment=FORGEJO__server__SSH_PORT=${toString ports.forgejoSsh}

    [Service]
    Restart=always
    RestartSec=5s
    TimeoutStartSec=5min
    TimeoutStopSec=30s

    [Install]
    WantedBy=multi-user.target
  '';
}
