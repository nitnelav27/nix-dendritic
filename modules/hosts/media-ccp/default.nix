{ self, inputs, ... }: {
  
  flake.nixosConfigurations.media-ccp = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.mediaCCPConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
