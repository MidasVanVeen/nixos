{ lib, ... }:
let
  testDomains = [
    "git.localhost"
    "portfolio.localhost"
    "ntfy.localhost"
    "www.portfolio.localhost"
  ];
in
{
  imports = [
    ../profiles/headless-user.nix
    ../services
    ../services/caddy.nix
    ../services/forgejo.nix
    ../services/portfolio.nix
    ../services/ntfy.nix
  ];

  networking.hostName = "test";
  my.user.name = "midas";

  fileSystems."/" = {
    device = lib.mkDefault "tmpfs";
    fsType = lib.mkDefault "tmpfs";
  };
  boot.loader.grub.device = lib.mkDefault "nodev";

  my.services = {
    ports = {
      ssh = 22;
      caddyHTTPS = 443;
      forgejo = 3000;
      forgejoSsh = 2222;
      portfolio = 4000;
      ntfy = 2586;
    };

    domains = {
      forgejo = "git.localhost";
      portfolio = "portfolio.localhost";
      ntfy = "ntfy.localhost";
    };

    urls = {
      forgejo = "https://git.localhost:8443/";
      ntfy = "https://ntfy.localhost:8443/";
    };

    redirects."www.portfolio.localhost" = "portfolio.localhost:8443";
    publicTCP = [ "caddyHTTPS" "forgejoSsh" ];
  };

  services.caddy.virtualHosts = lib.genAttrs testDomains (_: {
    extraConfig = lib.mkAfter "tls internal";
  });

  virtualisation.vmVariant.security.sudo.wheelNeedsPassword = false;

  virtualisation.vmVariant.virtualisation = {
    graphics = false;
    memorySize = 4096;
    cores = 4;
    diskSize = 16384;
    forwardPorts = [
      {
        host.address = "127.0.0.1";
        host.port = 8443;
        guest.port = 443;
      }
      {
        host.address = "127.0.0.1";
        host.port = 2222;
        guest.port = 2222;
      }
      {
        host.address = "127.0.0.1";
        host.port = 22222;
        guest.port = 22;
      }
    ];
  };

  system.stateVersion = "25.11";
}
