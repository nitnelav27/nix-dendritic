{ self, inputs, ... }: {

  flake.nixosModules.vvhGnome = { config, lib, pkgs, ... }: {

    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "sddm-astronaut-theme";
          package = pkgs.kdePackages.sddm;
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
      sddm-astronaut
    ];
  };
}
