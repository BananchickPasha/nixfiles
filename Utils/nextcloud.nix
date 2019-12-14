{ config, lib, pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.tld";
    nginx.enable = true;
    https = false;
    skeletonDirectory = "/home/banan/LocalDiskF";
    config = {
      adminpassFile = "/etc/nixos/keys/nextcloud/password";
      adminuser = "banan";
      overwriteProtocol = "http";
      extraTrustedDomains = [
        "192.168.31.91"
        "localhost"
      ];
    };
  };
}
