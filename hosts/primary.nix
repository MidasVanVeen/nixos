{
  imports = [
    ../hardware/hertzner
    ../profiles/headless-user.nix
    ../modules/system/comin.nix
    ../services
    ../services/caddy.nix
    ../services/forgejo.nix
    ../services/portfolio
    ../services/ntfy.nix
  ];

  networking.hostName = "primary";
  my.user.name = "midas";

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
      forgejo = "git.midasvanveen.com";
      portfolio = "midasvanveen.com";
    };

    redirects = {
      "www.midasvanveen.com" = "midasvanveen.com";
    };

    publicTCP = [ "forgejoSsh" ];
    cloudflareTCP = [ "caddyHTTPS" ];
  };

  system.stateVersion = "25.11";
}
