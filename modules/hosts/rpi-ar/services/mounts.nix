{ self, inputs, ... }: {

  flake.nixosModules.rpiArMounts = { config, lib, pkgs, ... }: {

    fileSystems = {
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
