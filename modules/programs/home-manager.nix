{ self, inputs, ... }: {

  flake.nixosModules.commonHomeManager = { config, pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { hostname = config.networking.hostName; };
    };
  };
}
