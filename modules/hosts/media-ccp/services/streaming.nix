{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPStreaming = { config, lib, pkgs, ... }: {

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

      navidrome = {
        enable = true;
        user = "vvh";
        group = "vvh";
        openFirewall = true;
        settings = {
          MusicFolder = "/storage/media/music";
          Address = "0.0.0.0";
          Agents = "lastfm";
          EnableDownloads = true;
          LastFM.ApiKey = "5f37d35b6d747c320e50d3b35bb1d88b";
          LastFM.Secret = "d92ade2859ff571931d9d505fa7212c8";
          Scanner.Schedule = "27 * * * *";
        };
      };
    };
  };
}
