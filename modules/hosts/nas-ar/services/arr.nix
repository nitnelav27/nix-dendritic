{ self, inputs, ... }: {

  flake.nixosModules.nasArArr = { config, lib, pkgs, ... }: {

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

    ## These dataDirs/ReadWritePaths must exist before the services start --
    ## on a fresh host nothing else creates them, which is what caused
    ## 226/NAMESPACE (ReadWritePaths source missing) on first boot.
    systemd.tmpfiles.rules = [
      "d /home/vvh/appData 0755 vvh vvh -"
      "d /home/vvh/appData/radarr 0755 vvh vvh -"
      "d /home/vvh/appData/sonarr 0755 vvh vvh -"
      "d /home/vvh/appData/lidarr 0755 vvh vvh -"
      "d /home/vvh/appData/prowlarr 0755 vvh vvh -"
      "d /home/vvh/appData/bazarr 0755 vvh vvh -"
    ];
  };
}
