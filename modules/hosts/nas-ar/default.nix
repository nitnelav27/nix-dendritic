{ self, inputs, ... }: {

  flake.nixosConfigurations.nas-ar = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.nasArConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
