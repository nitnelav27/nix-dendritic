{ self, inputs, ... }: {

  ## Everything around the compositor on n1pro -- bar, launcher,
  ## notifications, idle/lock, clipboard history, polkit agent -- shared by
  ## the sway and niri sessions. Long-running pieces are systemd user
  ## services on graphical-session.target, which both sway-session.target
  ## (homeModules.vvhSway) and niri.service (nixosModules.niriN1pro) pull in,
  ## so they start and stop with whichever session is logged in.
  flake.homeModules.n1proWaylandDesktop = { config, lib, pkgs, ... }:
    let
      ## swayidle runs outside the compositor, so pick the DPMS command by
      ## the session it was started for.
      dpms = state: pkgs.writeShellScript "dpms-${state}" ''
        case "$XDG_CURRENT_DESKTOP" in
          *sway*) exec /run/current-system/sw/bin/swaymsg 'output * dpms ${state}' ;;
          *niri*) ;;
          *) [ -n "$NIRI_SOCKET" ] || exec /run/current-system/sw/bin/swaymsg 'output * dpms ${state}' ;;
        esac
        ${if state == "off" then "exec /run/current-system/sw/bin/niri msg action power-off-monitors" else "true # niri wakes outputs on input by itself"}
      '';
    in {

    ## Clipboard history -- reuses the same cliphist your other hosts run,
    ## just needs wl-clipboard's wl-paste/wl-copy on PATH (see home.packages).
    services.cliphist = {
      enable = true;
      extraOptions = [ "-max-items" "1000" "-max-dedupe-search" "20" ];
    };

    systemd.user.services.polkit-gnome-agent = {
      Unit = {
        Description = "polkit-gnome authentication agent";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    ###################
    ### IDLE / LOCK ###
    ###################
    ## Same 5min lock / 5.5min DPMS-off timings as hypridle.nix, for parity.
    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 300; command = "swaylock -f"; }
        {
          timeout = 330;
          command = "${dpms "off"}";
          resumeCommand = "${dpms "on"}";
        }
      ];
      events = {
        before-sleep = "swaylock -f";
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "1d2021";
        font-size = 24;
        indicator-idle-visible = false;
        ignore-empty-password = true;
        show-failed-attempts = true;
      };
    };

    ################
    ### LAUNCHER ###
    ################
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMonoNL Nerd Font Mono:size=12";
          terminal = "ghostty -e";
          layer = "overlay";
          lines = 12;
          width = 40;
          horizontal-pad = 16;
          vertical-pad = 10;
          inner-pad = 6;
        };
        colors = {
          background = "1d2021ee";
          text = "ebdbb2ff";
          prompt = "83a598ff";
          input = "ebdbb2ff";
          match = "fabd2fff";
          selection = "3c3836ff";
          selection-text = "ebdbb2ff";
          selection-match = "fabd2fff";
          border = "83a598ff";
        };
        border = {
          width = 2;
          radius = 4;
        };
      };
    };

    ###########
    ### BAR ###
    ###########
    programs.waybar = {
      enable = true;
      systemd.enable = true; # WantedBy graphical-session.target
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        ## Both compositors' modules are listed; the one whose IPC socket
        ## isn't there just fails to load and is dropped from the bar.
        modules-left = [ "niri/workspaces" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "niri/language" "cpu" "memory" "pulseaudio" "network" "tray" ];

        "sway/workspaces".disable-scroll = true;
        "niri/workspaces".format = "{value}";
        "niri/language".format = "{short}";

        clock = {
          format = "{:%H:%M   %a %d %b}";
          tooltip = false;
        };

        ## 5s polling instead of the usual 1s -- fewer wakeups on a weak
        ## N150, matches the "reduce idle CPU churn" advice from earlier.
        cpu = {
          interval = 5;
          format = "  {usage}%";
        };
        memory = {
          interval = 5;
          format = "  {used:0.1f}G";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  muted";
          format-icons.default = [ "" "" "" ];
          on-click = "pwvucontrol";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ifname}";
          format-disconnected = "  offline";
        };

        tray.spacing = 8;
      };

      style = ''
        * {
          font-family: "JetBrainsMonoNL Nerd Font Mono";
          font-size: 13px;
          min-height: 0;
        }
        window#waybar {
          background: rgba(29, 32, 33, 0.90);
          color: #ebdbb2;
        }
        #workspaces button {
          padding: 0 6px;
          color: #a89984;
        }
        #workspaces button.focused,
        #workspaces button.active {
          color: #ebdbb2;
          border-bottom: 2px solid #83a598;
        }
        #clock, #cpu, #memory, #pulseaudio, #network, #tray, #language {
          padding: 0 8px;
        }
      '';
    };

    ######################
    ### NOTIFICATIONS ###
    ######################
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000;
        background-color = "#1d2021ee";
        text-color = "#ebdbb2";
        border-color = "#83a598";
        border-size = 2;
        border-radius = 4;
        padding = "10";
        font = "JetBrainsMonoNL Nerd Font Mono 11";
        anchor = "top-right";
        "urgency=critical" = {
          border-color = "#fb4934";
          default-timeout = 0;
        };
      };
    };

    ## grim/slurp (sway screenshots), swaybg (solid background in both
    ## sessions), wl-clipboard (cliphist), playerctl + brightnessctl (media
    ## keys), pwvucontrol (waybar volume click).
    home.packages = with pkgs; [
      grim
      slurp
      swaybg
      wl-clipboard
      playerctl
      brightnessctl
      pwvucontrol
    ];

    home.pointerCursor = {
      gtk.enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
