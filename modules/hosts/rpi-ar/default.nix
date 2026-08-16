{ self, inputs, ... }: {

  flake.nixosConfigurations.rpi-ar = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpiArConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
