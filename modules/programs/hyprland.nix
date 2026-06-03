{ self, inputs, ... }: {

  flake.homeModules.vvhHyprland = { config, lib, pkgs, ... }: {

    ## Hyprland config
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings = {
        monitor = [
          #"DP-3, 3440x1440@99.98, 0x0, 1"
          #"DP-4, 3840x2160@60.00, 0x0, 1.2"
          #"HDMI-A-1, 3440x1440@99.98, 0x0, 1"
          "DP-1, 2560x1440@180.00, 0x0, 1"
          "DP-2, 2560x1440@180.00, 2560x0, 1"
        ];
        ## Local variables
        "$terminal" = "ghostty";
        "$fileManager" = "thunar";
        "$menu" = "rofi -show drun";
        "$SwitchLayout" = "hyprctl -q switchxkblayout current next";
        #################
        ### AUTOSTART ###
        #################
        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:
        exec-once = [
          "fcitx5 -d -r"
          "$HOME/.config/hypr/scripts/xdg_bar"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "thunderbird"
          "firefox"
          "slack"
        ];
        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
        #####################
        ### LOOK AND FEEL ###
        #####################
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "master";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = "1.0";
          inactive_opacity = "1.0";
          shadow =  {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
          
          blur =  {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = "0.1696";
          };
        };
        
        animations =  {
          enabled = "yes, please :)";
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };
        master = {
          new_status = "slave";
          mfact = 0.67;
        };

        misc = {
          force_default_wallpaper = "-1"; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
        };

        #############
        ### INPUT ###
        #############
        input = {
          kb_layout = "us,es";
          kb_variant = "";
          kb_model = "pc105";
          kb_options = "grp:caps_toggle";
          follow_mouse = 1;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          touchpad = {
            natural_scroll = false;
          };
        };

        ###################
        ### KEYBINDINGS ###
        ###################
        "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier
        bind = [
          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, exit,"
          "$mainMod SHIFT, E, exec, $fileManager"
          "$mainMod SHIFT, F, togglefloating,"
          "$mainMod, Space, exec, $menu" # rofi in wayland 
          "$mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "$mainMod, P, pseudo," # dwindle
          #"$mainMod, J, togglesplit," # dwindle
          "$mainMod SHIFT, K, exec, $SwitchLayout"
          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          # Example special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          # Screenshots of a region
          "$mainMod SHIFT, P, exec, $HOME/.config/scripts/screenshot"
        ];
        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        bindel = [
          # Laptop multimedia keys for volume and LCD brightness
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];
        bindl = [
          # Requires playerctl
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################
        ##### Workspace rules
        workspace = [
          "1,default:true,monitor:DP-1"
          "2,monitor:DP-1"
          "3,monitor:DP-1"
          "4,monitor:DP-1"
          "5,monitor:DP-1"
          "6,monitor:DP-2"
          "7,monitor:DP-2"
          "8,monitor:DP-2"
          "9,monitor:DP-2"
          "10,monitor:DP-2"
        ];

        ###### Window rules
        windowrule = [
          "match:class firefox, workspace 1"
          "match:class thunderbird, workspace 6"
          "match:class Slack, workspace 7"
          "match:class teams-for-linux, workspace 8"
          "match:class emacs, workspace 2"
        ];
      };
    };

    programs.hyprlock.enable = true; 

  };
}
