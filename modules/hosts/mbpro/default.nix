{ self, inputs, ... }: {

  flake.darwinConfigurations.mbpro = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.darwinModules.mbproConfig
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };
      }
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "vvh";
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
          };
          mutableTaps = false;
        };
      }
      inputs.mac-app-util.darwinModules.default
    ];
  };
}
