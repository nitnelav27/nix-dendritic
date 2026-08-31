{ self, inputs, ... }: {

  flake.nixosModules.nasArStreaming = { config, lib, pkgs, ... }: {

    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
        user = "vvh";
        group = "vvh";
        dataDir = "/home/vvh/appData/jellyfin/data";
        configDir = "/home/vvh/appData/jellyfin/config";
        cacheDir = "/home/vvh/appData/jellyfin/cache";
        logDir = "/home/vvh/appData/jellyfin/log";
      };

      # navidrome = {
      #   enable = true;
      #   user = "vvh";
      #   group = "vvh";
      #   openFirewall = true;
      #   settings = {
      #     MusicFolder = "/storage/media/music";
      #     Address = "0.0.0.0";
      #     Agents = "lastfm";
      #     EnableDownloads = true;
      #     LastFM.ApiKey = "5f37d35b6d747c320e50d3b35bb1d88b";
      #     LastFM.Secret = "d92ade2859ff571931d9d505fa7212c8";
      #     Scanner.Schedule = "27 * * * *";
      #   };
      # };
    };

    ## jellyfin's dataDir/configDir/cacheDir/logDir must exist before it
    ## starts -- missing on a fresh host is exactly what produced
    ## 200/CHDIR (jellyfin couldn't chdir into its WorkingDirectory).
    systemd.tmpfiles.rules = [
      "d /home/vvh/appData 0755 vvh vvh -"
      "d /home/vvh/appData/jellyfin 0755 vvh vvh -"
      "d /home/vvh/appData/jellyfin/data 0755 vvh vvh -"
      "d /home/vvh/appData/jellyfin/config 0755 vvh vvh -"
      "d /home/vvh/appData/jellyfin/cache 0755 vvh vvh -"
      "d /home/vvh/appData/jellyfin/log 0755 vvh vvh -"
    ];
  };
}
