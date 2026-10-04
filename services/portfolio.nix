{ config, pkgs, ... }:
let
  sourceRevision = "02d790baae3a97b951ef7cd0a4d1d7ecf10a7510";
  sourceDirectory = "/var/lib/portfolio/source";
  dataDirectory = "/var/lib/portfolio/data";
  imageName = "localhost/portfolio:${sourceRevision}";
  port = config.my.services.ports.portfolio;
in
{
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d ${dataDirectory} 0750 root root -"
  ];

  systemd.services.portfolio-source = {
    description = "Prepare portfolio source and database";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = [ pkgs.git pkgs.coreutils ];
    script = ''
      if [ ! -d ${sourceDirectory}/.git ]; then
        git clone --branch main \
          https://github.com/MidasVanVeen/portfolio.git ${sourceDirectory}
      fi

      if ! git -C ${sourceDirectory} cat-file -e ${sourceRevision}; then
        git -C ${sourceDirectory} fetch origin main
      fi
      git -C ${sourceDirectory} checkout --detach --force ${sourceRevision}

      if [ ! -e ${dataDirectory}/portfolio.db ]; then
        install -m 0640 ${sourceDirectory}/portfolio.db \
          ${dataDirectory}/portfolio.db
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "5min";
    };
  };

  environment.etc."containers/systemd/portfolio.build".text = ''
    [Unit]
    Description=Build portfolio image
    Requires=portfolio-source.service
    After=portfolio-source.service

    [Build]
    ImageTag=${imageName}
    File=${sourceDirectory}/Dockerfile
    SetWorkingDirectory=${sourceDirectory}

    [Service]
    TimeoutStartSec=15min
  '';

  environment.etc."containers/systemd/portfolio.container".text = ''
    [Unit]
    Description=Midas van Veen's portfolio website
    Wants=network-online.target
    After=network-online.target

    [Container]
    Image=portfolio.build
    ContainerName=portfolio
    PublishPort=127.0.0.1:${toString port}:4000
    Volume=${dataDirectory}:/data:Z
    Environment=DATABASE=/data/portfolio.db

    [Service]
    Restart=on-failure
    RestartSec=5s
    TimeoutStartSec=15min
    TimeoutStopSec=15s

    [Install]
    WantedBy=multi-user.target
  '';
}
