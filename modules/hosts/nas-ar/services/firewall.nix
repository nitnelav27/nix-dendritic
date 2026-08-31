{ self, inputs, ... }: {

  ## Samba's ports are opened via `services.samba.openFirewall = true` (see
  ## samba.nix); openssh's port is opened automatically by that module.
  ## NFS ports below mirror rpi-ar/services/firewall.nix.
  flake.nixosModules.nasArFirewall = { config, lib, pkgs, ... }:
    let
      portList = [
        ### NFS
        111
        2049
        4000
        4001
        4002
        20048
        ### NFS ENDS HERE
        8080 ## qbittorrent
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
