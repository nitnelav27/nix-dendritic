{ self, inputs, ... }: {

  flake.nixosModules.commonHomeManager = { pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
