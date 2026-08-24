{ self, inputs, ... }: {
  
  ## Deliberately using nixos-raspberrypi's own nixosSystem helper (not
  ## inputs.nixpkgs.lib.nixosSystem) -- see rpi-ar/default.nix for why.
  flake.nixosConfigurations.rpiCCP = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      self.nixosModules.rpiCCPConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
