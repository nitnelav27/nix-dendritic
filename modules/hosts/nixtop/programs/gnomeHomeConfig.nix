{ self, inputs, ... }: {

  flake.homeModules.nixtopGnomeHomeConfig = { config, lib, pkgs, ... }: {

    dconf = {
      enable = true;
    };
  };
}
