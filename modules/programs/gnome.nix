{ self, inputs, ... }: {

  flake.nixosModules.vvhGnome = { config, lib, pkgs, ... }: {

    services = {
      displayManager = {
        gdm = {
          enable = false;
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
    ];
  };
}
