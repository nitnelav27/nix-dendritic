{ self, inputs, ... }: {

  ## Deliberately using nixos-raspberrypi's own nixosSystem helper (not
  ## inputs.nixpkgs.lib.nixosSystem): it pins its own nixpkgs internally
  ## (see the `nixos-raspberrypi` input comment in the top-level flake.nix)
  ## and auto-injects the `nixos-raspberrypi` special arg that its own
  ## modules (raspberry-pi-5.base, sd-image, ...) expect.
  flake.nixosConfigurations.rpi-ar = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      self.nixosModules.rpiArConfig
      self.nixosModules.commonHomeManager
    ];
  };
}
