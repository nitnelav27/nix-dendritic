{ self, inputs, ... }: {

  ## Sway itself is enabled system-wide via `programs.sway` in the host's
  ## NixOS configuration.nix (that's what provides the actual `sway` binary,
  ## the display-manager session entry, and the XDG portal wiring). This
  ## home-manager module only owns the *config file* -- keybindings, bar,
  ## idle/lock behaviour -- the same split hyprland.nix uses.
  flake.homeModules.vvhSway = { config, lib, pkgs, ... }:
    let
      mod = "Mod4"; # SUPER, matches $mainMod on hyprland and Mod on niri
      theme = self.lib.n1proTheme pkgs; # same wallpaper/palette as the niri session
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
          "*" = {
            bg = "${theme.wallpaper} fill";
          };
        };

        colors = {
          focused = {
            border = theme.colors.primary;
            background = theme.colors.primary;
            text = theme.colors.on_primary;
            indicator = theme.colors.tertiary;
            childBorder = theme.colors.primary;
          };
          unfocused = {
            border = theme.colors.outline_variant;
            background = theme.colors.surface;
            text = theme.colors.on_surface_variant;
            indicator = theme.colors.outline_variant;
            childBorder = theme.colors.outline_variant;
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
          "${mod}+Ctrl+v" = "exec clipboard-menu"; # same as niri / daru
          "Mod1+x" = "exec power-menu";            # Alt+X, same as niri / daru
          "${mod}+Shift+p" =
            ''exec grim -g "$(slurp)" "$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"'';
        };

        #################
        ### AUTOSTART ###
        #################
        startup = [
            #{ command = "waybar"; }
          { command = "mako"; }
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

    ## Bar, launcher, notifications, idle/lock, clipboard, polkit agent,
    ## cursor: shared with the niri session in homeModules.n1proWaylandDesktop.
  };
}
