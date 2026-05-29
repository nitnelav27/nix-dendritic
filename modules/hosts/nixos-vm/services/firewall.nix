{ self, inputs, ... }: {

  flake.nixosModules.nixosVmFirewall = { pkgs, lib, ... }:
    let
      portList = [
        80    ## npm
        443   ## npm
        8082  ## Homepage
        8080  ## qbittorrent
        8096  ## jellyfin
      ];
      in
  {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = portList;
        allowedUDPPorts = portList;
      };
    };
}
