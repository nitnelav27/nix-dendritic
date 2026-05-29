{ self, inputs, ... }: {

  flake.nixosModules.nixosVmFirewall = { pkgs, lib, ... }:
    let
      portList = [
        80    ## npm
        443   ## npm
        8082  ## Homepage
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
