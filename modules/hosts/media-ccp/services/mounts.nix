{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPMounts = { config, lib, pkgs, ... }: {

    filesystems = {
      #### Disk mounts 
      ## MEDIA HDD
      "/storage/media" = {
        device = "/dev/disk/by-uuid/6fadb1cd-4f4a-4ae7-818b-a46a0c403a92";
        fsType = "ext4";
      };
      ## NAS SSD
      "/storage/nas" = {
        device = "/dev/disk/by-uuid/3acfea27-9081-4a46-bfc1-22fcc6806eb5";
        fsType = "ext4";
      };
      ## Decreto HDD
      "/storage/.decreto" = {
        device = "/dev/disk/by-uuid/7d290586-4681-4dbc-9176-7afe20381b64";
        fsType = "ext4";
      };
      ## TORRENTS SSD
      "/storage/torrents" = {
        device = "/dev/disk/by-uuid/8a116a4a-9084-441e-bf3b-d1be77c8f132";
        fsType = "ext4";
      };
      
      ## BIND MOUNTS: calibre 
      "/export/calibre" = {
        device = "/storage/nas/calibre";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: data
      "/export/data" = {
        device = "/storage/nas/data";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: dump 
      "/export/dump" = {
        device = "/storage/nas/dump";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: migration
      "/export/migration" = {
        device = "/storage/nas/migration";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: docs
      "/export/docs" = {
        device = "/storage/nas/docs";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: results
      "/export/results" = {
        device = "/storage/nas/results";
        fsType = "none";
        options = [ "bind" ];
      };
      ## BIND MOUNTS: decreto
      "/export/.decreto" = {
        device = "/storage/.decreto";
        fsType = "none";
        options = [ "bind" ];
      };
    };
  };
}
