{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPArr = { config, lib, pkgs, ... }: {

    services = {
      radarr = {
        enable = true;
        openFirewall = true;
        user = "vvh";
        group = "vvh";
        dataDir = "/home/vvh/appData/radarr";
      };
      sonarr = {
        enable = true;
        openFirewall = true;
        dataDir = "/home/vvh/appData/sonarr";
        user = "vvh";
        group = "vvh";
      };
      lidarr = {
        enable = true;
        user = "vvh";
        group = "vvh";
        openFirewall = true;
        dataDir = "/home/vvh/appData/lidarr";
      };
      prowlarr = {
        enable = true;
        openFirewall = true;
        dataDir = "/home/vvh/appData/prowlarr";
        settings = {
          update.automatically = true;
          update.mechanism = "builtIn";
        };
      };
      bazarr = {
        enable = true;
        dataDir = "/home/vvh/appData/bazarr";
        openFirewall = true;
        user = "vvh";
        group = "vvh";
      };
    };

    systemd.services = {
      radarr.serviceConfig = {
        # Use lib.mkForce to resolve the conflict with the default module
        ProtectHome = lib.mkForce "read-only"; 
        ReadWritePaths = [ "/home/vvh/appData/radarr" ];
      };
      sonarr.serviceConfig = {
        # Use lib.mkForce to resolve the conflict with the default module
        ProtectHome = lib.mkForce "read-only"; 
        ReadWritePaths = [ "/home/vvh/appData/sonarr" ];
      };
    };
  };
}
