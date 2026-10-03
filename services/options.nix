{ lib, ... }:
{
  options.my.services = {
    ports = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { ssh = 22; };
      description = "Host-owned listening ports, keyed by service name.";
    };

    domains = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Public hostnames for services exposed through Caddy.";
    };

    urls = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "External service URLs when they differ from their local listeners.";
    };

    redirects = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Hostnames redirected to another HTTPS hostname.";
    };

    publicTCP = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Service port names reachable from any source.";
    };

    cloudflareTCP = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Service port names reachable only from Cloudflare proxy IP ranges.";
    };

  };
}
