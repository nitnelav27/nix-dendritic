{ self, inputs, ... }: {

  flake.nixosModules.vvhGnome = { config, lib, pkgs, ... }:
  let
    # Pick a variant: astronaut, black_hole, cyberpunk, hyprland_kath,
    # jake_the_dog, japanese_aesthetic, pixel_sakura, pixel_sakura_static,
    # post-apocalyptic_hacker, purple_leaves
    sddmTheme = pkgs.sddm-astronaut.override {
      embeddedTheme = "astronaut";
    };
  in {

    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          package = pkgs.kdePackages.sddm;
          theme = "sddm-astronaut-theme";
          # The greeter only sees QML modules passed here; systemPackages is not enough.
          extraPackages = [
            sddmTheme
            pkgs.kdePackages.qtmultimedia
            pkgs.kdePackages.qtsvg
            pkgs.kdePackages.qtvirtualkeyboard
          ];
          settings.General.InputMethod = "qtvirtualkeyboard";
        };
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
      };
      gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
    };

    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      sddmTheme
    ];
  };
}
