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
        listenPort = 8082;
        environmentFiles = [
          config.age.secrets."homepage-env".path
        ];

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              uptime = true;
              disk = "/";
            };
          }
          {
            jellyfin = {
              url = "http://10.27.115.4:8096";
              href = "https://medusa.rengo1136.org";
              key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
              enableBlocks = true;
              enableNowPlaying = true;
              enableUser = true;
              enableMediaControl = false;
              showEpisodeNumber = true;
              expandOneStremToTwoRows = false;
            };
          }
          {
            qbittorrent = {
              url = "http://10.27.115.4:8080";
              href = "https://bt.rengo1136.org";
              username = "vvh";
              password = "{{HOMEPAGE_VAR_QBITTORRENT_PASS}}";
              enableLeechProgress = true;
            };
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
