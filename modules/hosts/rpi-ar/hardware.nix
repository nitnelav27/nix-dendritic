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

    ## generic-extlinux-compatible defaults to writing extlinux.conf +
    ## copied kernel/initrd/dtbs to plain "/boot" — since only
    ## "/boot/firmware" is a real mountpoint here (the SD card's FAT
    ## partition; "/boot" itself is just a directory on the NVMe root
    ## ext4 fs), that default silently lands everything somewhere the
    ## Pi's firmware can never read (it has no ext4 support at all).
    ## Point it at the actual firmware partition instead.
    boot.loader.generic-extlinux-compatible.mirroredBoots = [
      { path = "/boot/firmware"; }
    ];

    ## Mainline kernel (cached on cache.nixos.org) instead of linux-rpi.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    boot.kernel.sysctl."vm.mmap_rnd_bits" = lib.mkForce 28;
    boot.tmp.useTmpfs = true;
  };
}
