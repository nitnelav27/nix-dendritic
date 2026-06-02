{ self, inputs, ... }: {

  flake.nixosModules.vvhGnome = { config, lib, pkgs, ... }: {

    displayManager = {
      gdm = {
        enable = true;
      };
      #defaultSession = "gnome";
    };
    desktopManager.gnome.enable = true;
    ## Disable all of gnome's bloat
    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
    };

    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
    ];
  };
}
