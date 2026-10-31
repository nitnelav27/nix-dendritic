{ self, inputs, ... }: {

  ## Two wrapped niri packages built from one shared base:
  ##   vvhNiri       -> nixtop (Noctalia shell, pinned DP-1/DP-2 outputs)
  ##   vvhNiriN1pro  -> n1pro  (waybar + fuzzel + mako + swayidle/swaylock,
  ##                            all owned by homeModules.n1proWaylandDesktop)
  ## Keybinds, workspaces, input and layout come from `base`, so muscle
  ## memory is identical on both machines; each host only layers its own
  ## outputs, startup programs and launcher on top.

  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.vvhNiri;
    };
  };

  flake.nixosModules.niriN1pro = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.vvhNiriN1pro;
    };
  };

  perSystem = { pkgs, lib, self', ... }:
    let
      ## Named workspaces, in order. nixtop pins them to outputs; n1pro
      ## leaves them floating (see n1pro below).
      workspaceNames = [ "01main" "02browse" "03code" "04comms" "05read" "06terms" ];

      workspaceBinds = lib.listToAttrs (lib.concatLists (lib.imap1 (i: ws: [
        { name = "Mod+${toString i}";       value.focus-workspace = ws; }
        { name = "Mod+Shift+${toString i}"; value.move-column-to-workspace = ws; }
      ]) workspaceNames));

      base = {
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input = {
          keyboard.xkb = {
            layout = "us,es";
            options = "grp:caps_toggle";
          };
          disable-power-key-handling = true;
        };

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = _: {};

          "Mod+F".maximize-column       = _: {};
          "Mod+G".fullscreen-window     = _: {};
          "Mod+Shift+F".toggle-window-floating = _: {};
          "Mod+C".center-column         = _: {};

          "Mod+Left".focus-column-left  = _: {};
          "Mod+Right".focus-column-right = _: {};
          "Mod+Up".focus-window-up      = _: {};
          "Mod+Down".focus-window-down  = _: {};

          "Mod+Shift+H".move-column-left  = _: {};
          "Mod+Shift+L".move-column-right = _: {};
          "Mod+Shift+K".move-window-up    = _: {};
          "Mod+Shift+J".move-window-down  = _: {};
        } // workspaceBinds;
      };

      ## Media/brightness keys that keep working on the lock screen.
      lockedSpawn = cmd: _: {
        props.allow-when-locked = true;
        content.spawn-sh = cmd;
      };
    in {

    packages.vvhNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = lib.recursiveUpdate base {
        spawn-at-startup = [
          (lib.getExe self'.packages.vvhNoctalia)
        ];

        outputs = {
          "DP-1" = {
            mode = "2560x1440@180.001";
            scale = 1.0;
            position = _: { props = { x = 0; y = 0; }; };
            #variable-refresh-rate = _: {};
            hot-corners = { off = _: {}; };
          };
          "DP-2" = {
            mode = "2560x1440@180.003";
            scale = 1.0;
            position = _: { props = { x = 2560; y = 0; }; };
            #variable-refresh-rate = _: {};
            hot-corners = { off = _: {}; };
          };
        };

        workspaces = {
          "01main"  = { open-on-output = "DP-1"; };
          "02browse" = { open-on-output = "DP-1"; };
          "03code"  = { open-on-output = "DP-1"; };
          "04comms" = { open-on-output = "DP-2"; };
          "05read"  = { open-on-output = "DP-2"; };
          "06terms" = { open-on-output = "DP-2"; };
        };

        binds."Mod+Space".spawn-sh = "${lib.getExe self'.packages.vvhNoctalia} ipc call launcher toggle";
      };
    };

    packages.vvhNiriN1pro = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = lib.recursiveUpdate base {
        ## waybar, swayidle and cliphist are systemd user services bound to
        ## graphical-session.target (niri.service pulls that in), and the
        ## polkit agent is too -- see homeModules.n1proWaylandDesktop. Only
        ## things without a unit get spawned here.
        spawn-at-startup = [
          [ (lib.getExe pkgs.swaybg) "-c" "#1d2021" ] # solid colour, same as the sway session
          (lib.getExe pkgs.mako)
        ];

        ## No `outputs` block: monitors are auto-configured. Once the
        ## monitors are attached, run `niri msg outputs` and pin modes /
        ## positions here (and `open-on-output` below) like nixtop does.
        ## When a monitor disappears its workspaces move to the remaining
        ## one, and niri moves them back when it reconnects.
        workspaces = lib.genAttrs workspaceNames (_: _: {});

        binds = {
          "Mod+Space".spawn = [ (lib.getExe pkgs.fuzzel) ];

          ## Things Noctalia provides on nixtop, done by hand here.
          "Mod+Alt+L".spawn-sh = "swaylock -f";
          "Ctrl+Alt+Delete".quit = _: {};
          "Mod+Shift+Slash".show-hotkey-overlay = _: {};
          "Mod+O".toggle-overview = _: {};
          "Mod+V".switch-focus-between-floating-and-tiling = _: {};

          ## Same as the n1pro sway session.
          "Mod+Shift+E".spawn = [ (lib.getExe pkgs.thunar) ];
          "Mod+Shift+P".screenshot = _: {}; # interactive; saved to ~/Pictures/Screenshots + clipboard

          "XF86AudioRaiseVolume" = lockedSpawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = lockedSpawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute"        = lockedSpawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute"     = lockedSpawn "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp"   = lockedSpawn "brightnessctl s 10%+";
          "XF86MonBrightnessDown" = lockedSpawn "brightnessctl s 10%-";
          "XF86AudioNext" = lockedSpawn "playerctl next";
          "XF86AudioPrev" = lockedSpawn "playerctl previous";
          "XF86AudioPlay" = lockedSpawn "playerctl play-pause";
          "XF86AudioPause" = lockedSpawn "playerctl play-pause";
        };
      };
    };
  };
}
