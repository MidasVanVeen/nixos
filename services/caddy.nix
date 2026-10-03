{ config, lib, ... }:
let
  inherit (config.my.services) ports domains redirects;
  httpEnabled = ports ? caddyHTTP;
  proxyHosts = lib.mapAttrs' (
    name: domain:
    lib.nameValuePair domain {
      extraConfig = "reverse_proxy localhost:${toString ports.${name}}";
    }
  ) domains;
  redirectHosts = lib.mapAttrs (
    _host: destination: {
      extraConfig = "redir https://${destination}{uri} permanent";
    }
  ) redirects;
in
{
  services.caddy = {
    enable = domains != { } || redirects != { };
    globalConfig = ''
      ${lib.optionalString httpEnabled "http_port ${toString ports.caddyHTTP}"}
      https_port ${toString ports.caddyHTTPS}
      ${lib.optionalString (!httpEnabled) ''
        auto_https disable_redirects
        cert_issuer acme {
          disable_http_challenge
        }
      ''}
    '';
    virtualHosts = proxyHosts // redirectHosts;
  };
}
