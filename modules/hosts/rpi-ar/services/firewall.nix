{ self, inputs, ... }: {

  flake.nixosModules.rpiArFirewall = { pkgs, lib, ... }:
    let
      portList = [
        ### NFS
        111
        2049
        4000
        4001
        4002
        20048
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
