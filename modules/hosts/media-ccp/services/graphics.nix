{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPGraphics = { config, lib, pkgs, ... }: {

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
