{ self, inputs, ... }: {

  ## PLACEHOLDER storage disk -- fill in the real by-uuid device path once
  ## the storage disk(s) are partitioned/formatted on the target machine.
  ## The /export/* bind mounts and directory layout below mirror
  ## rpi-ar/services/mounts.nix, since nas-ar is meant to replace it and
  ## should serve the same NFS exports from the same relative paths.
  flake.nixosModules.nasArMounts = { config, lib, pkgs, ... }: {

    fileSystems = {
      ## TODO: replace with the real storage disk, e.g.:
      # "/storage" = {
      #   device = "/dev/disk/by-uuid/REPLACE-ME";
      #   fsType = "ext4";
      # };

      "/export/.decreto" = {
        device = "/storage/.decreto";
        fsType = "none";
        options = [ "bind" ];
      };
      "/export/data" = {
        device = "/storage/data";
        fsType = "none";
        options = [ "bind" ];
      };
      "/export/docs" = {
        device = "/storage/docs";
        fsType = "none";
        options = [ "bind" ];
      };
      "/export/dump" = {
        device = "/storage/dump";
        fsType = "none";
        options = [ "bind" ];
      };
      "/export/results" = {
        device = "/storage/results";
        fsType = "none";
        options = [ "bind" ];
      };
      "/export/calibre" = {
        device = "/storage/calibre";
        fsType = "none";
        options = [ "bind" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /storage/.decreto 0775 vvh vvh -"
      "d /storage/data 0775 vvh vvh -"
      "d /storage/docs 0775 vvh vvh -"
      "d /storage/dump 0775 vvh vvh -"
      "d /storage/results 0775 vvh vvh -"
      "d /storage/calibre 0775 vvh vvh -"
    ];
  };
}
