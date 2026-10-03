{ config, lib, ... }:
let
  inherit (config.my.services) ports publicTCP cloudflareTCP;
  resolve = names: builtins.map (name: ports.${name}) names;
  cloudflarePorts = resolve cloudflareTCP;

  # https://www.cloudflare.com/ips/
  cloudflareIPv4 = [
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
  ];
  cloudflareIPv6 = [
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];
  allowFrom = command: ranges:
    lib.concatMapStrings (range:
      lib.concatMapStrings (port: ''
        ${command} -w -A nixos-fw -p tcp --dport ${toString port} -s ${range} -j nixos-fw-accept
      '') cloudflarePorts
    ) ranges;
in
{
  assertions = [
    {
      assertion = lib.intersectLists (resolve publicTCP) cloudflarePorts == [ ];
      message = "A TCP port cannot be both publicTCP and cloudflareTCP.";
    }
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = resolve publicTCP;
    extraCommands = ''
      ${allowFrom "iptables" cloudflareIPv4}
      ${allowFrom "ip6tables" cloudflareIPv6}
    '';
  };
}
