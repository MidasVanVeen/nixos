{ config, ... }:
let
  port = config.my.services.ports.ntfy;
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = config.my.services.urls.ntfy or "http://${config.networking.hostName}:${toString port}";
      listen-http = "0.0.0.0:${toString port}";
    };
  };
}
