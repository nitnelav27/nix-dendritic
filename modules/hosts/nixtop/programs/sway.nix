{ self, inputs, ... }: {

  ## Sway session on nixtop, mirroring packages.vvhNiri in
  ## modules/programs/niri.nix: same binds, named workspaces pinned to
  ## DP-1/DP-2, same input and gaps. Deliberately WITHOUT Noctalia: a light
  ## session built from swaybar + i3status, rofi, mako and swaylock, all
  ## started by sway itself so none of it leaks into the niri session.
  ## Pick "Sway" in SDDM.
  ##
  ## Split like n1pro: the NixOS module installs sway and registers the
  ## session; the home-manager module owns the config file.

  flake.nixosModules.nixtopSway = { pkgs, ... }: {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      ## Proprietary NVIDIA driver: sway refuses to start without this.
      extraOptions = [ "--unsupported-gpu" ];
    };
    ## Screen sharing / screenshots for wlroots (niri brings its own portal).
    xdg.portal.wlr.enable = true;
  };

  flake.homeModules.nixtopSway = { lib, pkgs, ... }:
    let
      mod = "Mod4";
      ## Nord, matching the Noctalia theme used under niri.
      nord = {
        bg = "#2e3440"; bgAlt = "#3b4252"; fg = "#eceff4"; fgDim = "#d8dee9";
        accent = "#88c0d0"; outline = "#4c566a"; urgent = "#bf616a";
      };
      wallpaper = "/home/vsvh/pix/wp2/riverforest.jpg"; # same as noctalia.toml

      ## Same names/order as `workspaceNames` in niri.nix.
      workspaces = [
        { name = "01main";   output = "DP-1"; }
        { name = "02browse"; output = "DP-1"; }
        { name = "03code";   output = "DP-1"; }
        { name = "04comms";  output = "DP-2"; }
        { name = "05read";   output = "DP-2"; }
        { name = "06terms";  output = "DP-2"; }
      ];

      workspaceBinds = lib.listToAttrs (lib.concatLists (lib.imap1 (i: ws: [
        { name = "${mod}+${toString i}";       value = "workspace ${ws.name}"; }
        { name = "${mod}+Shift+${toString i}"; value = "move container to workspace ${ws.name}"; }
      ]) workspaces));
    in {

    home.packages = with pkgs; [ swaylock mako wl-clipboard ];

    ## Media keys (sway only; Noctalia/niri handle their own).
    wayland.windowManager.sway.extraConfig = ''
      bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym --locked XF86AudioPlay exec playerctl play-pause
      bindsym --locked XF86AudioNext exec playerctl next
      bindsym --locked XF86AudioPrev exec playerctl previous
    '';

    wayland.windowManager.sway = {
      enable = true;
      package = null; # system programs.sway provides the wrapped binary
      systemd.enable = true;
      systemd.variables = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "SWAYSOCK"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "NIXOS_OZONE_WL"
        "LIBVA_DRIVER_NAME"
        "GBM_BACKEND"
        "__GLX_VENDOR_LIBRARY_NAME"
      ];

      config = {
        modifier = mod;
        terminal = "ghostty";
        menu = "rofi -show drun";

        bars = [ {
          position = "top";
          statusCommand = lib.getExe pkgs.i3status;
          fonts = { names = [ "Fira Sans" ]; size = 10.0; };
          trayOutput = "*";
          colors = {
            background = nord.bg;
            statusline = nord.fgDim;
            separator = nord.outline;
            focusedWorkspace  = { border = nord.accent;  background = nord.accent; text = nord.bg; };
            activeWorkspace   = { border = nord.outline; background = nord.bgAlt;  text = nord.fg; };
            inactiveWorkspace = { border = nord.bg;      background = nord.bg;     text = nord.fgDim; };
            urgentWorkspace   = { border = nord.urgent;  background = nord.urgent; text = nord.bg; };
          };
        } ];

        colors = {
          focused   = { border = nord.accent;  background = nord.accent; text = nord.bg;    indicator = nord.accent;  childBorder = nord.accent; };
          unfocused = { border = nord.outline; background = nord.bg;     text = nord.fgDim; indicator = nord.outline; childBorder = nord.outline; };
        };

        gaps.inner = 5; # niri: layout.gaps = 5

        window = {
          border = 2;
          titlebar = false;
        };
        floating.titlebar = false;

        input."type:keyboard" = {
          xkb_layout = "us,es";
          xkb_options = "grp:caps_toggle";
        };

        output = {
          "*".bg = "${wallpaper} fill";
          "DP-1" = { mode = "2560x1440@180.001Hz"; position = "0 0"; };
          "DP-2" = { mode = "2560x1440@180.003Hz"; position = "2560 0"; };
        };

        workspaceOutputAssign =
          map (ws: { workspace = ws.name; inherit (ws) output; }) workspaces;

        defaultWorkspace = "workspace 01main";

        ## The niri bind set, translated. Replaces sway's defaults entirely
        ## (like niri, which has no default binds) plus reload.
        keybindings = {
          "${mod}+Return" = "exec ${lib.getExe pkgs.ghostty}";
          "${mod}+q" = "kill";
          "${mod}+Space" = "exec rofi -show drun";

          ## niri maximize-column has no sway equivalent; both map to fullscreen.
          "${mod}+f" = "fullscreen toggle";
          "${mod}+g" = "fullscreen toggle";
          "${mod}+Shift+f" = "floating toggle";
          "${mod}+c" = "move position center"; # niri center-column (floating windows here)

          "${mod}+Left" = "focus left";
          "${mod}+Right" = "focus right";
          "${mod}+Up" = "focus up";
          "${mod}+Down" = "focus down";

          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+l" = "move right";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+j" = "move down";

          "${mod}+Shift+r" = "reload";

          ## What Noctalia provides under niri, done by hand here.
          "${mod}+Mod1+l" = "exec swaylock -f -i ${wallpaper}";
          "Ctrl+Mod1+Delete" = "exit";
          "${mod}+Ctrl+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
          "${mod}+Shift+n" = "exec makoctl restore";
        } // workspaceBinds;

        startup = [ { command = lib.getExe pkgs.mako; } ];
      };
    };
  };
}
