{ self, inputs, ... }: {
  flake.nixosConfigurations.nixos-vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.nixosVmConfig
    ];
  };
}
