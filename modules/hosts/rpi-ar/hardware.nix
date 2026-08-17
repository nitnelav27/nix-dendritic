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

    ## NVMe-only layout: no SD card involved at all anymore. The Pi 5's boot
    ## ROM reads FAT directly off whichever device BOOT_ORDER points it at
    ## (SD, NVMe, USB, ...), so the firmware partition has to live on NVMe
    ## itself -- it's not something the EEPROM can source from elsewhere.
    ## nvme0n1p1 = firmware (2GB, FAT32), p2 = root (100GB), p3 = home (rest).
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/8f70eead-f971-4bf7-b244-d87ee3bd93b6";
        fsType = "ext4";
      };

      "/home" = {
        device = "/dev/disk/by-uuid/984146ed-1a3e-45f3-82c2-2f1fd241bab8";
        fsType = "ext4";
      };

      "/boot/firmware" = {
        device = "/dev/disk/by-uuid/1699-7A34";
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
