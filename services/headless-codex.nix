{ config, pkgs, ... }:
let
  sourceDirectory = "/var/lib/headless-codex/source";
  dataDirectory = "/var/lib/headless-codex/data";
  projectsDirectory = "/var/lib/headless-codex/projects";
  homeDirectory = "/var/lib/headless-codex/home";
  revisions = {
    m_headless_codex = "a51118137823b4ec2e954be32abdce0f5e4d87b1";
    m_codeviewer = "831916d60981692fde2382dc01ff02211c7b9d92";
    m_headless_git = "2db409e9f8d441974b9556277f62fc170bccacd3";
    m_mdviewer = "e66cca397c5e901e49a971de29cc763a50f87fb9";
  };
  imageRevision = builtins.substring 0 12 (builtins.hashString "sha256" (
    builtins.concatStringsSep ":" (builtins.attrValues revisions)
  ));
  imageName = "localhost/m-headless-codex:${imageRevision}";
  inherit (config.my.services) ports;
in
{
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/headless-codex 0755 root root -"
    "d ${sourceDirectory} 0750 root root -"
    "d ${dataDirectory} 0750 1000 1000 -"
    "d ${projectsDirectory} 0750 1000 1000 -"
    "d ${homeDirectory} 0750 1000 1000 -"
  ];

  systemd.services.headless-codex-source = {
    description = "Prepare headless Codex source repositories";
    # The Git server shares this host's short name, so use its Tailscale IP.
    wants = [ "network-online.target" "tailscaled.service" ];
    after = [ "network-online.target" "tailscaled.service" ];

    path = [ pkgs.git pkgs.openssh pkgs.coreutils ];
    script = ''
      if [ ! -r /root/.ssh/id_ed25519 ]; then
        echo "Missing /root/.ssh/id_ed25519 for private Git repositories" >&2
        exit 1
      fi

      export GIT_SSH_COMMAND='ssh -i /root/.ssh/id_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes'

      prepare_repo() {
        name="$1"
        revision="$2"
        directory="${sourceDirectory}/$name"
        url="ssh://git@100.106.63.14:222/midas/$name"

        if [ ! -d "$directory/.git" ]; then
          git clone --branch main "$url" "$directory"
        fi
        git -C "$directory" remote set-url origin "$url"
        if ! git -C "$directory" cat-file -e "$revision^{commit}"; then
          git -C "$directory" fetch origin main
        fi
        git -C "$directory" checkout --detach --force "$revision"
      }

      prepare_repo m_headless_codex ${revisions.m_headless_codex}
      prepare_repo m_codeviewer ${revisions.m_codeviewer}
      prepare_repo m_headless_git ${revisions.m_headless_git}
      prepare_repo m_mdviewer ${revisions.m_mdviewer}
    '';

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "10min";
    };
  };

  systemd.services.headless-codex-ssh-key = {
    description = "Prepare headless Codex Git identity";
    path = [ pkgs.openssh pkgs.coreutils ];
    script = ''
      sshDirectory=${homeDirectory}/.ssh
      install -d -m 0700 -o 1000 -g 1000 "$sshDirectory"

      if [ ! -e "$sshDirectory/id_ed25519" ]; then
        ssh-keygen -q -t ed25519 -N "" -f "$sshDirectory/id_ed25519" -C headless-codex@primary-1
        chown 1000:1000 "$sshDirectory/id_ed25519" "$sshDirectory/id_ed25519.pub"
      fi

      if [ ! -e "$sshDirectory/known_hosts" ] && [ -r /root/.ssh/known_hosts ]; then
        install -m 0644 -o 1000 -g 1000 /root/.ssh/known_hosts "$sshDirectory/known_hosts"
      fi
    '';
    serviceConfig.Type = "oneshot";
  };

  environment.etc."containers/systemd/headless-codex.build".text = ''
    [Unit]
    Description=Build headless Codex image
    Requires=headless-codex-source.service
    After=headless-codex-source.service

    [Build]
    ImageTag=${imageName}
    File=${sourceDirectory}/m_headless_codex/Dockerfile
    SetWorkingDirectory=${sourceDirectory}/m_headless_codex
    PodmanArgs=--build-context=codeviewer=${sourceDirectory}/m_codeviewer --build-context=gitclient=${sourceDirectory}/m_headless_git --build-context=mdviewer=${sourceDirectory}/m_mdviewer

    [Service]
    TimeoutStartSec=60min
  '';

  environment.etc."containers/systemd/headless-codex.container".text = ''
    [Unit]
    Description=Headless Codex workspace
    Wants=network-online.target
    After=network-online.target
    Requires=headless-codex-ssh-key.service
    After=headless-codex-ssh-key.service

    [Container]
    Image=headless-codex.build
    ContainerName=headless-codex
    Network=host
    Volume=${dataDirectory}:/data:Z
    Volume=${projectsDirectory}:/projects:Z
    Volume=${homeDirectory}:/home/headless:Z

    [Service]
    Restart=on-failure
    RestartSec=5s
    TimeoutStartSec=10min
    TimeoutStopSec=30s

    [Install]
    WantedBy=multi-user.target
  '';

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    ports.headlessCodex
    ports.headlessCodexSsh
  ];
}
