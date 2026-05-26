{ self, inputs, ... }: {

  flake.nixosModules.commonConfig = { pkgs, lib, ... }: {

    ## Settings
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    ## Garbage Collection
    nix.gc = {
      automatic = true;
      dates = "Fri *-*-* 12:00:00";
      options = "--delete-older-than 30d";
    };
  };
}
