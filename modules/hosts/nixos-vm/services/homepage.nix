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
          title = "Valentin's Homepage";
          headerStyle = "boxedWidgets";
          useEqualHeights = true;
          layout = [
            {
              "Media & Downloads" = {
                style = "row";
                columns = 4;
              };
            }
            {
              "Arr" = {
                style = "row";
                columns = 4;
              };
            }
            {
              "Waste Time" = {
                style = "column";
              };
            }
            {
              "Work" = {
                style = "column";
              };
            }
            {
              "Buy Stuff" = {
                style = "column";
              };
            }
            {
              "Administration" = {
                style = "column";
              };
            }
          ];
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
          {
            greeting = {
              text_size = "2xl";
              text = "Hello... Newman!";
            };
          }
          {
            openmeteo = {
              label = "Concepción";
              latitude = -36.82056;
              longitude = -73.05646;
              timezone = "America/Santiago";
              units = "metric";
            };
          }
          {
            datetime = {
              text_size = "xl";
              locale = "en";
              format = {
                dateStyle = "long";
                timeStyle = "short";
                hourCycle = "h23";
              };
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
                  description = "My media server";
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
                "Navidrome" = {
                  icon = "navidrome";
                  href = "https://play.rengo1136.org";
                  description = "Lossless music";
                  widget = {
                    type = "navidrome";
                    url = "http://10.27.115.4:4533";
                    user = "vvh";
                    token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
                    salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
                  };
                };
              }
              {
                "qBittorrent" = {
                  icon = "qbittorrent";
                  href = "https://bt.rengo1136.org";
                  description = "Bittorrent client";
                  widget = {
                    type = "qbittorrent";
                    url = "http://10.27.115.4:8080";
                    username = "vvh";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASS}}";
                  };
                };
              }
              {
                "Prowlarr" = {
                  icon = "prowlarr";
                  href = "https://downs.rengo1136.org";
                  description = "Torrent meta search";
                  widget = {
                    type = "prowlarr";
                    url = "http://10.27.115.4:9696";
                    key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                  };
                };
              }
            ];
          }
          {
            "Arr" = [
              {
                "Radarr" = {
                  icon = "radarr";
                  href = "https://film.rengo1136.org";
                  description = "Movies";
                  widget = {
                    type = "radarr";
                    url = "http://10.27.115.4:7878";
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    enableQueue = true;
                  };
                };
              }
              {
                "Sonarr" = {
                  icon  = "sonarr";
                  href = "https://tv.rengo1136.org";
                  description = "TV";
                  widget = {
                    type = "sonarr";
                    url = "http://10.27.115.4:8989";
                    key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                    enableQueue = true;
                  };
                };
              }
              {
                "Lidarr" = {
                  icon = "lidarr";
                  href = "https://music.rengo1136.org";
                  description = "Music";
                  widget = {
                    type = "lidarr";
                    url = "http://10.27.115.4:8686";
                    key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
                  };
                };
              }
              {
                "Bazarr" = {
                  icon = "bazarr";
                  href = "https://subs.rengo1136.org";
                  description = "Subtitles";
                  widget = {
                    type = "bazarr";
                    url = "http://10.27.115.4:6767";
                    key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
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
                    description = "My site manager";
                  }
                ];
              }
              {
                "Github" = [
                  {
                    abbr = "GH";
                    href = "https://github.com/nitnelav27?tab=repositories";
                    icon = "sh-github-dark";
                    description = "My repositories";
                  }
                ];
              }
            ];
          }
          {
            "Work" = [
              {
                "Overleaf" = [
                  {
                    abbr = "OV";
                    href = "https://www.overleaf.com/project";
                    icon = "sh-overleaf";
                    description = "My projects";
                  }
                ];
              }
              {
                "Gemini" = [
                  {
                    abbr = "GG";
                    href = "https://gemini.google.com";
                    icon = "sh-google-gemini";
                    description = "Chat interface";
                  }
                ];
              }
            ];
          }
          {
            "Waste Time" = [
              {
                "Youtube" = [
                  {
                    abbr = "YT";
                    href = "https://www.youtube.com/";
                    icon = "sh-youtube";
                    description = "My youtube homepage";
                  }
                ];
              }
              {
                "Reddit" = [
                  {
                    abbr = "RD";
                    href = "https://www.reddit.com/";
                    icon = "sh-reddit";
                    description = "The sewage of the Internet";
                  }
                ];
              }
            ];
          }
          {
            "Buy Stuff" = [
              {
                "MELI" = [
                  {
                    abbr = "ML";
                    href = "https://www.mercadolibre.cl/";
                    icon = "si-mercadopago";
                    description = "Mercado Libre Chile";
                  }
                ];
              }
              {
                "Ali Express" = [
                  {
                    abbr = "AE";
                    href = "https://aliexpress.com";
                    icon = "sh-aliexpress";
                    description = "Chinos";
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
