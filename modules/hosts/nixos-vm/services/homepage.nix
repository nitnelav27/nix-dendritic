{ self, inputs, ... }: {

  flake.nixosModules.vvhHomepage = { config, lib, pkgs, ... }: {

    age.secrets = {
      "homepage-env" = {
        file = self + "/secrets/homepage-secrets.age";
      };
    };

    services = {
      homepage-dashboard = {
        enable = true;
        openFirewall = true;
        listenPort = 8082;
        environmentFiles = [
          config.age.secrets."homepage-env".path
        ];
        settings = {
          title = "Testing Homepage";
          layout = {
            "Media & Downloads" = {
              style = "row";
              columns = 4;
            };
            "Arr" = {
              style = "row";
              columns = 4;
            };
          };
        };

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              uptime = true;
              disk = "/";
            };
          }
        ];

        services = [
          {
            "Media & Downloads" = [
              {
                "Jellyfin" = {
                  icon = "jellyfin";
                  href = "https://medusa.rengo1136.org";
                  widget = {
                    type = "jellyfin";
                    url = "http://10.27.115.4:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                    enableBlocks = true;
                    enableNowPlaying = true;
                    enableUser = true;
                    showEpisodeNumber = true;
                  };
                };
              }
              {
                "qBittorrent" = {
                  icon = "qbittorrent";
                  href = "https://bt.rengo1136.org";
                  widget = {
                    type = "qbittorrent";
                    url = "http://10.27.115.4:8080";
                    username = "vvh";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASS}}";
                  };
                };
              }
            ];
            "Arr" = [
              {
                "Radarr" = {
                  icon = "radarr";
                  href = "https://film.rengo1136.org";
                  widget = {
                    type = "radarr";
                    url = "https://10.27.115.4:7878";
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    enableQueue = true;
                  };
                };
              }
            ];
          }
        ];

        bookmarks = [
          {
            "Administration" = [
              {
                "Ubiquiti" = [
                  {
                    abbr = "UI";
                    href = "https://unifi.ui.com/";
                    icon = "si-ubiquiti";
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    systemd.services.homepage-dashboard.environment = {
      HOMEPAGE_ALLOWED_HOSTS = lib.mkForce "10.27.115.3:8082,localhost:8082,127.0.0.1:8082";
    };
  };
}
