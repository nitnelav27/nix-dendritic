{ self, inputs, ... }: {

  flake.nixosModules.nixosVmFirewall = { pkgs, lib, ... }:
    let 
    portList = [
      80    ## npm
      81    ## npm
      443   ## npm
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
