{ self, inputs, ... }: {
  
  flake.nixosConfigurations.nixtop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.nixtopConfig
      self.nixosModules.commonHomeManager
      inputs. solaar.nixosModules.default
    ];
  };
}
