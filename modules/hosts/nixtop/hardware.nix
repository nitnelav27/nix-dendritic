{ self, inputs, ... }: {

  flake.nixosModules.nixtopHardware = { config, lib, pkgs, modulesPath, ... }: {

    imports = [ 
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/6dff7583-25a7-4c90-aa49-a1f28a5f7e3e";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/B26D-3F18";
        fsType = "vfat";
        options = [ 
          "fmask=0077"
          "dmask=0077" 
        ];
      };

      "/home" = {
        device = "/dev/disk/by-uuid/8ef996c7-0450-41a8-b7de-6dc0182363ce";
        fsType = "ext4";
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
