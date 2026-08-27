{ self, inputs, ... }: {

  flake.nixosModules.nasArSamba = { config, lib, pkgs, ... }: {

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "nas-ar";
          "netbios name" = "nas-ar";
          "security" = "user";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "10.27.81. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };

        ## TODO: point this at a real path once storage mounts exist
        ## (see mounts.nix).
        # "share" = {
        #   "path" = "/storage/share";
        #   "browseable" = "yes";
        #   "read only" = "no";
        #   "guest ok" = "no";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "vvh";
        #   "force group" = "vvh";
        # };
      };
    };
  };
}
