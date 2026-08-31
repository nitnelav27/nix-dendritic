{ self, inputs, ... }: {

  flake.nixosModules.nasArGraphics = { config, lib, pkgs, ... }: {

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-ocl
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };
  };
}
