{ self, inputs, ... }: {

  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.vvhNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.vvhNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.vvhNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input = {
          keyboard.xkb = {
            layout = "us,es";
          };
          disable-power-key-handling = true;
        };

        outputs = {
          "DP-1" = {
            mode = "2560x1440@180.001";
            scale = 1.0;
            position = _: { props = { x = 0; y = 0; }; };
            variable-refresh-rate = _: {};
            hot-corners = { off = _: {}; };
          };
          "DP-2" = {
            mode = "2560x1440@180.003";
            scale = 1.0;
            position = _: { props = { x = 2560; y = 0; }; };
            variable-refresh-rate = _: {};
            hot-corners = { off = _: {}; };
          };
        };

        workspaces = {
          "main"  = { open-on-output = "DP-1"; };
          "browse" = { open-on-output = "DP-1"; };
          "code"  = { open-on-output = "DP-1"; };
          "comms" = { open-on-output = "DP-2"; };
          "read"  = { open-on-output = "DP-2"; };
          "terms" = { open-on-output = "DP-2"; };
        };

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = _: {};
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.vvhNoctalia} ipc call launcher toggle";

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

          "Mod+1".focus-workspace = "main";
          "Mod+2".focus-workspace = "browse";
          "Mod+3".focus-workspace = "code";
          "Mod+4".focus-workspace = "comms";
          "Mod+5".focus-workspace = "read";
          "Mod+6".focus-workspace = "terms";

          "Mod+Shift+1".move-column-to-workspace = "main";
          "Mod+Shift+2".move-column-to-workspace = "browse";
          "Mod+Shift+3".move-column-to-workspace = "code";
          "Mod+Shift+4".move-column-to-workspace = "comms";
          "Mod+Shift+5".move-column-to-workspace = "read";
          "Mod+Shift+6".move-column-to-workspace = "terms";
        };
      };
    };
  };
}
