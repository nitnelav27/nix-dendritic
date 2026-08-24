{ self, inputs, ... }: {

  flake.nixosModules.rpiCCPHardware = { config, lib, pkgs, ... }: {
    imports = [
      ## Pi 5 board profile from nixos-raspberrypi: downstream kernel (cached
      ## via nixos-raspberrypi.cachix.org), bcm2712 device trees, NVMe/PCIe
      ## initrd modules. Replaces nixos-hardware.raspberry-pi-5 +
      ## generic-extlinux-compatible -- see rpi-ar for why (the same
      ## missing-mirroredBoots class of bug this host was also exposed to).
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
    ];

    ## "kernel" mode: the Pi 5 firmware loads the kernel/initrd/DT directly
    ## per NixOS generation from /boot/firmware. No U-Boot, no extlinux.conf,
    ## no mirroredBoots.
    boot.loader.raspberry-pi.bootloader = "kernel";

    fileSystems = {
      "/" = { 
        device = "/dev/disk/by-uuid/7dbe295d-3f2b-42dc-b8ba-bbfd95db9278";
        fsType = "ext4";
      };

      "/home" = {
        device = "/dev/disk/by-uuid/cf3101ee-f74c-4a0a-8393-285e57c76219";
        fsType = "ext4";
      };

      ## NOTE: this UUID is from the current SD card and WILL change once you
      ## reflash with the new rpi-ccp-installer image. Update it via
      ## `blkid /dev/mmcblk0p1` after the fresh install boots.
      "/boot/firmware" = {
        device = "/dev/disk/by-uuid/8E41-276D";
        fsType = "vfat";
        options = [ "nofail" "fmask=0077" "dmask=0077" ];
      };
    };

    ## No swap partition on the SD card: zram instead (cheap on 8/16 GB, and it
    ## does not chew through flash write cycles).
    swapDevices = [ ];
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    ## Wi-Fi / Bluetooth blobs for the BCM43455.
    hardware.enableRedistributableFirmware = true;

    ## nixos-raspberrypi's own downstream kernel is used now (cached via
    ## nixos-raspberrypi.cachix.org, so no more 45-90 min on-device builds) --
    ## no need to force mainline anymore like the old nixos-hardware setup did.
    boot.kernel.sysctl."vm.mmap_rnd_bits" = lib.mkForce 28;
    ## Reduce SD-card wear: build sandboxes and /tmp in RAM.
    boot.tmp.useTmpfs = true;
  };
}
