{ self, inputs, ... }: {

  flake.nixosModules.rpiArHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      ## Pi 5 board profile: bcm2712 device trees, extlinux, disables GRUB,
      ## initrd modules for NVMe/PCIe/RP1.
      inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/83d82ac0-edf1-49e8-9223-ae9897046d45";
        fsType = "ext4";
      };

      "/home" = {
        device = "/dev/disk/by-uuid/30c1beca-1b89-4ad5-939d-712e18d85bbf";
        fsType = "ext4";
      };

      "/boot/firmware" = {
        device = "/dev/disk/by-uuid/2178-694E";
        fsType = "vfat";
        options = [ "nofail" "fmask=0077" "dmask=0077" ];
      };

      "/storage" = {
        device = "/dev/disk/by-uuid/cf30920a-71d9-4458-8468-1650e721980c";
        fsType = "ext4";
      };
    };

    ## No swap partition: zram instead.
    swapDevices = [ ];
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    hardware.enableRedistributableFirmware = true;

    ## Mainline kernel (cached on cache.nixos.org) instead of linux-rpi.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    boot.kernel.sysctl."vm.mmap_rnd_bits" = lib.mkForce 28;
    boot.tmp.useTmpfs = true;
  };
}
