{ self, inputs, ... }: {

  ## Everything around the compositor on n1pro -- bar, launcher,
  ## notifications, idle/lock, clipboard history, polkit agent -- shared by
  ## the sway and niri sessions. Long-running pieces are systemd user
  ## services on graphical-session.target, which both sway-session.target
  ## (homeModules.vvhSway) and niri.service (nixosModules.niriN1pro) pull in,
  ## so they start and stop with whichever session is logged in.
  ##
  ## Look modelled on daru (github.com/beefsizzle/daru): translucent top bar
  ## over a blurred wallpaper, square workspace pips, clock+weather pill in
  ## the middle, Adwaita Sans; every colour comes from self.lib.n1proTheme
  ## (theme.nix -- currently Nord, matching nvf).
  flake.homeModules.n1proWaylandDesktop = { config, lib, pkgs, ... }:
    let
      theme = self.lib.n1proTheme pkgs;
      c = theme.colors;
      inherit (theme) hex rgba;

      weatherLocation = "Buenos+Aires";

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

      ## daru's Alt+X power dropdown, as a fuzzel dmenu. Works in both sessions.
      powerMenu = pkgs.writeShellScriptBin "power-menu" ''
        choice=$(printf '%s\n' \
          "󰌾  Lock" "󰍃  Log out" "󰤄  Suspend" "󰜉  Reboot" "󰐥  Shut down" \
          | ${lib.getExe pkgs.fuzzel} --dmenu --prompt "power ❯ " --lines 5 --width 18) || exit 0
        case "$choice" in
          *Lock) swaylock -f ;;
          *"Log out")
            case "$XDG_CURRENT_DESKTOP" in
              *niri*) niri msg action quit --skip-confirmation ;;
              *)      swaymsg exit ;;
            esac ;;
          *Suspend)     systemctl suspend ;;
          *Reboot)      systemctl reboot ;;
          *"Shut down") systemctl poweroff ;;
        esac
      '';

      ## daru's Mod+Ctrl+V clipboard dropdown, over cliphist.
      clipboardMenu = pkgs.writeShellScriptBin "clipboard-menu" ''
        ${lib.getExe pkgs.cliphist} list \
          | ${lib.getExe pkgs.fuzzel} --dmenu --prompt "clip ❯ " --width 60 \
          | ${lib.getExe pkgs.cliphist} decode \
          | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      ## Weather pill next to the clock (daru shows it there too). wttr.in,
      ## metric, refreshed every 15 min; silent when offline.
      weather = pkgs.writeShellScript "waybar-weather" ''
        out=$(${lib.getExe pkgs.curl} -sf --max-time 10 \
          "https://wttr.in/${weatherLocation}?m&format=%c|%t|%C|%f|%w|%h") \
          || { echo '{"text":"","class":"offline"}'; exit 0; }
        IFS='|' read -r icon temp cond feels wind hum <<< "$out"
        icon=$(echo $icon)
        ${lib.getExe pkgs.jq} -nc \
          --arg text "$icon ''${temp#+}" \
          --arg tooltip "$cond · feels ''${feels#+} · wind $wind · humidity $hum" \
          '{text: $text, tooltip: $tooltip}'
      '';

      ## Bell / bell-off, like daru's "Quiet" toggle. Refreshed on SIGRTMIN+8.
      makoctl = "${pkgs.mako}/bin/makoctl";
      notifications = pkgs.writeShellScript "waybar-notifications" ''
        if ${makoctl} mode | grep -qx do-not-disturb; then
          echo '{"text":"󰂛","class":"dnd","tooltip":"Quiet: notifications hidden"}'
        else
          echo '{"text":"󰂚","tooltip":"Notifications (click: quiet, right-click: last one)"}'
        fi
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

    ## Wallpaper behind a translucent ring, in the theme colours.
    programs.swaylock = {
      enable = true;
      settings = {
        image = "${theme.wallpaper}";
        scaling = "fill";
        font = "Adwaita Sans";
        font-size = 22;
        indicator-radius = 90;
        indicator-thickness = 6;
        indicator-idle-visible = false;
        ignore-empty-password = true;
        show-failed-attempts = true;

        inside-color = "${hex "surface"}cc";
        inside-clear-color = "${hex "surface"}cc";
        inside-ver-color = "${hex "surface_container_high"}cc";
        inside-wrong-color = "${hex "error_container"}cc";
        ring-color = "${hex "outline_variant"}ff";
        ring-clear-color = "${hex "tertiary"}ff";
        ring-ver-color = "${hex "primary"}ff";
        ring-wrong-color = "${hex "error"}ff";
        key-hl-color = "${hex "primary"}ff";
        bs-hl-color = "${hex "error"}ff";
        text-color = "${hex "on_surface"}ff";
        text-clear-color = "${hex "on_surface"}ff";
        text-ver-color = "${hex "on_surface"}ff";
        text-wrong-color = "${hex "on_error_container"}ff";
        line-color = "00000000";
        line-clear-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        separator-color = "00000000";
      };
    };

    ################
    ### LAUNCHER ###
    ################
    ## niri gives the "launcher" layer the same frosted blur as the bar.
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "Adwaita Sans:size=12";
          prompt = "\"❯ \"";
          terminal = "ghostty -e";
          layer = "overlay";
          icons-enabled = true;
          lines = 10;
          width = 36;
          horizontal-pad = 18;
          vertical-pad = 14;
          inner-pad = 8;
          line-height = 22;
        };
        colors = {
          background = "${hex "surface_container"}d9";
          text = "${hex "on_surface"}ff";
          prompt = "${hex "primary"}ff";
          placeholder = "${hex "outline"}ff";
          input = "${hex "on_surface"}ff";
          match = "${hex "primary"}ff";
          selection = "${hex "primary_container"}ff";
          selection-text = "${hex "on_primary_container"}ff";
          selection-match = "${hex "on_primary_container"}ff";
          border = "${hex "outline_variant"}ff";
        };
        border = {
          width = 1;
          radius = 8;
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
        spacing = 0;
        ## Both compositors' modules are listed; the one whose IPC socket
        ## isn't there just fails to load and is dropped from the bar.
        modules-left = [ "custom/launcher" "niri/workspaces" "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" "custom/weather" ];
        modules-right = [
          "tray" "niri/language" "cpu" "memory" "pulseaudio" "bluetooth"
          "custom/notifications" "custom/power"
        ];

        "custom/launcher" = {
          format = "";
          tooltip = false;
          on-click = lib.getExe pkgs.fuzzel;
        };

        ## Workspace "pips": the label is blank, CSS draws the squares.
        "niri/workspaces" = {
          format = " ";
          tooltip = false;
        };
        "sway/workspaces" = {
          format = " ";
          disable-scroll = true;
        };

        clock = {
          format = "{:%H:%M  <span foreground='${c.outline}'>%a %d %b</span>}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
            format = {
              months = "<span color='${c.on_surface}'><b>{}</b></span>";
              weekdays = "<span color='${c.outline}'><b>{}</b></span>";
              days = "<span color='${c.on_surface_variant}'>{}</span>";
              today = "<span color='${c.on_primary}' background='${c.primary}'><b> {} </b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "custom/weather" = {
          exec = "${weather}";
          return-type = "json";
          interval = 900;
        };

        "niri/language".format = "{short}";

        tray = {
          icon-size = 14;
          spacing = 8;
        };

        ## 5s polling instead of the usual 1s -- fewer wakeups on a weak
        ## N150, matches the "reduce idle CPU churn" advice from earlier.
        cpu = {
          interval = 5;
          format = "󰍛 {usage}%";
        };
        memory = {
          interval = 5;
          format = "󰘚 {percentage}%";
          tooltip-format = "{used:0.1f} / {total:0.1f} GiB";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
          on-click = "pwvucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-connected = "󰂱 {num_connections}";
          format-no-controller = ""; # hidden on units without a BT module
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
        };

        "custom/notifications" = {
          exec = "${notifications}";
          return-type = "json";
          interval = 30;
          signal = 8;
          on-click = "${makoctl} mode -t do-not-disturb; pkill -RTMIN+8 waybar";
          on-click-right = "${makoctl} restore";
        };

        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "power-menu";
        };
      };

      style = ''
        * {
          font-family: "Adwaita Sans", "JetBrainsMono Nerd Font";
          font-size: 12px;
          font-weight: 600;
          min-height: 0;
          border: none;
          border-radius: 0;
          box-shadow: none;
          text-shadow: none;
        }

        /* niri blurs whatever is behind this (layer-rule in niri.nix) */
        window#waybar {
          background: ${rgba "surface" 0.55};
          color: ${c.on_surface};
        }

        tooltip {
          background: ${rgba "surface_container" 0.95};
          border: 1px solid ${c.outline_variant};
          border-radius: 8px;
        }
        tooltip label { color: ${c.on_surface}; }

        .modules-left, .modules-center, .modules-right { margin: 3px 6px; }

        /* left: logo chip + workspace pips */
        #custom-launcher {
          color: ${c.primary};
          font-size: 15px;
          padding: 0 9px 0 7px;
          margin-right: 6px;
          border-radius: 5px;
          background: ${rgba "surface_container_high" 0.7};
        }
        #workspaces {
          padding: 0 5px;
          border-radius: 5px;
          background: ${rgba "surface_container_high" 0.7};
        }
        #workspaces button {
          min-width: 8px;
          min-height: 8px;
          font-size: 1px; /* blank label; the pip is the button itself */
          padding: 0;
          margin: 8px 2px;
          border-radius: 2px;
          background: ${c.outline_variant};
          transition: all 150ms ease;
        }
        #workspaces button.empty { background: ${rgba "outline_variant" 0.45}; }
        #workspaces button:hover { background: ${c.outline}; }
        #workspaces button.active,
        #workspaces button.focused {
          min-width: 22px;
          background: ${c.primary};
        }
        #workspaces button.urgent { background: ${c.error}; }
        #mode { padding: 0 8px; color: ${c.tertiary}; }

        /* centre: clock + weather as one pill */
        #clock, #custom-weather {
          padding: 0 10px;
          background: ${rgba "surface_container_high" 0.7};
        }
        #clock { border-radius: 5px 0 0 5px; padding-right: 6px; }
        #custom-weather { border-radius: 0 5px 5px 0; color: ${c.on_surface_variant}; }
        #custom-weather.offline { padding: 0; }

        /* right: quiet icons with values, like daru */
        #tray, #language, #cpu, #memory, #pulseaudio, #bluetooth,
        #custom-notifications, #custom-power {
          padding: 0 8px;
          color: ${c.on_surface_variant};
        }
        #cpu, #memory { color: ${c.tertiary}; }
        #pulseaudio.muted { color: ${c.outline}; }
        #bluetooth.connected { color: ${c.primary}; }
        #custom-notifications.dnd { color: ${c.outline}; }
        #custom-power { color: ${c.error}; padding-right: 4px; }
        #tray > .needs-attention { background: ${rgba "error" 0.3}; }
      '';
    };

    ######################
    ### NOTIFICATIONS ###
    ######################
    ## niri blurs the "notifications" layer; "Quiet" mode hides popups.
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000;
        width = 360;
        margin = "8";
        padding = "12";
        border-size = 1;
        border-radius = 8;
        font = "Adwaita Sans 11";
        icons = 1;
        max-icon-size = 40;
        anchor = "top-right";
        background-color = "${c.surface_container}d9";
        text-color = c.on_surface;
        border-color = c.outline_variant;
        progress-color = "over ${c.primary_container}";
        "urgency=critical" = {
          border-color = c.error;
          default-timeout = 0;
        };
        "mode=do-not-disturb" = {
          invisible = 1;
        };
      };
    };

    ## Terminal follows the theme too (daru's "ghostty" recolour target).
    ## Merges with the shared settings in homeModules.vvhTerminals.
    programs.ghostty.settings = {
      background = c.surface;
      foreground = c.on_surface;
      cursor-color = c.primary;
      selection-background = c.primary_container;
      selection-foreground = c.on_primary_container;
      ## ANSI 0-15 from the theme when it defines them (Nord does); a
      ## wallpaper-derived theme has none, so "Dark+" keeps them.
    } // lib.optionalAttrs (theme.ansi != null) {
      palette = lib.imap0 (i: color: "${toString i}=${color}") theme.ansi;
    };

    ## grim/slurp (sway screenshots), swaybg (wallpaper in both sessions),
    ## wl-clipboard (cliphist), playerctl + brightnessctl (media keys),
    ## pwvucontrol (waybar volume click), Adwaita Sans (daru's UI font),
    ## power-menu / clipboard-menu (Alt+X / Mod+Ctrl+V).
    home.packages = with pkgs; [
      grim
      slurp
      swaybg
      wl-clipboard
      playerctl
      brightnessctl
      pwvucontrol
      adwaita-fonts
      powerMenu
      clipboardMenu
    ];

    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
