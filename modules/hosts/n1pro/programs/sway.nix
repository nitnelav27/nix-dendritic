{ self, inputs, ... }: {

  ## Sway itself is enabled system-wide via `programs.sway` in the host's
  ## NixOS configuration.nix (that's what provides the actual `sway` binary,
  ## the display-manager session entry, and the XDG portal wiring). This
  ## home-manager module only owns the *config file* -- keybindings, bar,
  ## idle/lock behaviour -- the same split hyprland.nix uses.
  flake.homeModules.vvhSway = { config, lib, pkgs, ... }:
    let
      mod = "Mod4"; # SUPER, matches $mainMod on hyprland and Mod on niri
    in {

    wayland.windowManager.sway = {
      enable = true;
      ## Set to null: the system-level `programs.sway` package (see the
      ## host's configuration.nix) already puts a wrapped `sway` on PATH.
      ## Installing a second one here would just double the closure.
      package = null;
      systemd.enable = true; # pulls in sway-session.target -> graphical-session.target
      ## Default list already covers WAYLAND_DISPLAY/XDG_SESSION_TYPE/NIXOS_OZONE_WL;
      ## these two aren't in it by default, and apps launched via portal/dbus
      ## activation (not a login shell) won't otherwise see them -- meaning no
      ## Wayland-native Firefox/Electron and no VAAPI hw video decode for them.
      systemd.variables = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "SWAYSOCK"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "NIXOS_OZONE_WL"
        "XCURSOR_THEME"
        "XCURSOR_SIZE"
        "MOZ_ENABLE_WAYLAND"
        "LIBVA_DRIVER_NAME"
      ];

      config = {
        modifier = mod;
        terminal = "ghostty";
        menu = "rofi -show drun"; # same launcher/keybind as hyprland.nix
        bars = [ ]; # waybar replaces the built-in swaybar

        gaps = {
          inner = 4;
          outer = 2;
        };

        window = {
          border = 2;
          titlebar = false;
        };

        floating = {
          titlebar = false;
        };

        #############
        ### INPUT ###
        #############
        input = {
          "type:keyboard" = {
            xkb_layout = "us,es";
            xkb_options = "grp:caps_toggle"; # same layout/toggle as hyprland + niri
          };
          "type:touchpad" = {
            natural_scroll = "disabled";
            tap = "enabled";
          };
        };

        output = {
          ## Solid colour instead of an image: zero decode cost on the N150's
          ## iGPU. Point this at a file (e.g. "~/pix/wall.png fill") if you'd
          ## rather have a real wallpaper -- just know it's not "free".
          "*" = {
            bg = "#1d2021 solid_color";
          };
        };

        ###################
        ### KEYBINDINGS ###
        ###################
        ## Sway/i3's sane defaults (splits, resize mode, workspace 1-10,
        ## Mod+Shift+E exit-confirmation, Mod+minus scratchpad, ...) are kept.
        ## These just layer the handful of binds that match your hyprland/niri
        ## muscle memory on top, via mkOptionDefault.
        keybindings = lib.mkOptionDefault {
          "${mod}+q" = "kill";
          "${mod}+Shift+f" = "floating toggle";
          "${mod}+Shift+e" = "exec thunar";
          "${mod}+Shift+p" =
            ''exec grim -g "$(slurp)" "$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"'';
        };

        #################
        ### AUTOSTART ###
        #################
        startup = [
          { command = "waybar"; }
          { command = "mako"; }
          { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
          { command = "wl-paste --type text --watch cliphist store"; }
          { command = "wl-paste --type image --watch cliphist store"; }
        ];
      };

      extraConfig = ''
        # Media / backlight keys -- mirrors the bindel/bindl entries in hyprland.nix
        bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        bindsym XF86MonBrightnessUp exec brightnessctl s 10%+
        bindsym XF86MonBrightnessDown exec brightnessctl s 10%-
        bindsym XF86AudioNext exec playerctl next
        bindsym XF86AudioPrev exec playerctl previous
        bindsym XF86AudioPlay exec playerctl play-pause
        bindsym XF86AudioPause exec playerctl play-pause
      '';
    };

    ## Clipboard history -- reuses the same cliphist your other hosts run,
    ## just needs wl-clipboard's wl-paste/wl-copy on PATH (see home.packages).
    services.cliphist = {
      enable = true;
      extraOptions = [ "-max-items" "1000" "-max-dedupe-search" "20" ];
    };

    ###############
    ### IDLE / LOCK ###
    ###############
    ## Same 5min lock / 5.5min DPMS-off timings as hypridle.nix, for parity.
    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 300; command = "swaylock -f"; }
        {
          timeout = 330;
          command = "swaymsg 'output * dpms off'";
          resumeCommand = "swaymsg 'output * dpms on'";
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

    ###########
    ### BAR ###
    ###########
    programs.waybar = {
      enable = true;
      systemd.enable = true; # needs wayland.windowManager.sway.systemd.enable = true (set above)
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "pulseaudio" "network" "tray" ];

        "sway/workspaces".disable-scroll = true;

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
        #workspaces button.focused {
          color: #ebdbb2;
          border-bottom: 2px solid #83a598;
        }
        #clock, #cpu, #memory, #pulseaudio, #network, #tray {
          padding: 0 8px;
        }
      '';
    };

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

    ## grim/slurp (screenshot), swaybg (output.*.bg needs it -- sway doesn't
    ## decode images itself), wl-clipboard (cliphist watchers), playerctl +
    ## brightnessctl (media keys above), pwvucontrol (waybar volume click).
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
