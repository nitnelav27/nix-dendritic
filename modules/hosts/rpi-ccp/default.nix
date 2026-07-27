{ self, inputs, ... }: {
  
  flake.nixosConfigurations.rpiCCP = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpiCCPConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
