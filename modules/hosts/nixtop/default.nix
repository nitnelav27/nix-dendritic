{ self, inputs, ... }: {
  
  flake.nixosConfigurations.nixtop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.nixtopConfig
      self.nixosModules.commonHomeManager
      {
        nixpkgs.overlays = [
          inputs.nix-claude-code.overlays.default
        ];
      }
    ];
  };
}
