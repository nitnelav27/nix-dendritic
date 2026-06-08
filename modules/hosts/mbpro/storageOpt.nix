{ self, inputs, ... }: {

  flake.darwinModules.mbproStorageOpt = { config, lib, pkgs, ... }: {

    nix.optimise = {
      automatic = true;
      interval = {
        Hour = 12;
        Minute = 12;
        Weekday = 5;
      };
    };

    nix.gc = {
      automatic = true;
      interval = {
        Hour = 12;
        Minute = 55;
        Weekday = 4;
      };
      options = "--delete-older-than 30d";
    };
  };
}
