{ self, inputs, ... }: {

  flake.nixosModules.rpiArHardware = { config, lib, pkgs, ... }: {
    imports = [
      ## Pi 5 board profile from nixos-raspberrypi: downstream kernel (cached
      ## via nixos-raspberrypi.cachix.org), bcm2712 device trees, NVMe/PCIe
      ## initrd modules.
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
    ];

    ## "kernel" mode: the Pi 5 firmware loads the kernel/initrd/DT directly
    ## per NixOS generation from /boot/firmware. No U-Boot, no extlinux.conf,
    ## no mirroredBoots -- this replaces the generic-extlinux-compatible +
    ## nixos-hardware chain that was landing back on the installer's own
    ## root instead of rpi-ar's.
    boot.loader.raspberry-pi.bootloader = "kernel";

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/83d82ac0-edf1-49e8-9223-ae9897046d45";
        fsType = "ext4";
      };

      "/home" = {
        device = "/dev/disk/by-uuid/30c1beca-1b89-4ad5-939d-712e18d85bbf";
        fsType = "ext4";
      };

      ## NOTE: this UUID is from the pre-reflash SD card and WILL change once
      ## you reflash with the new rpi-ar-installer image. Update it via
      ## `blkid /dev/mmcblk0p1` after the fresh install boots.
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

    boot.kernel.sysctl."vm.mmap_rnd_bits" = lib.mkForce 28;
    boot.tmp.useTmpfs = true;
  };
}
