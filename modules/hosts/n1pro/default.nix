{ self, inputs, ... }: {

  flake.nixosConfigurations.n1pro = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.n1proConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
