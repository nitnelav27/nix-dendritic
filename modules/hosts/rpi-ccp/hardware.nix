{ self, inputs, ... }: {

  flake.nixosModules.rpiCCPHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports =[
      ## Pi 5 board profile: pins DTs to bcm2712, adds nvme/pcie-brcmstb/clk-rp1/rp1
      ## to the initrd, disables GRUB and enables extlinux generation.
      inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ];

    fileSystems = {
      "/" = { 
        device = "/dev/disk/by-uuid/7b5a0e42-ba43-4ac9-9adf-6a043935d6b5";
        fsType = "ext4";
      };

      "/home" = {
        device = "/dev/disk/by-uuid/cf3101ee-f74c-4a0a-8393-285e57c76219";
        fsType = "ext4";
      };

      "/boot/firmware" = {
        device = "/dev/disk/by-uuid/4135-5B63";
        fsType = "vfat";
        options = [ "nofail" "noauto" "fmask=0077" "dmask=0077" ];
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

    ## Mainline kernel instead of the profile's downstream linux-rpi.
    ## Rationale: linux-rpi is NOT in cache.nixos.org and takes ~45-90 min to
    ## build on the Pi itself (or hours under binfmt emulation). Mainline is
    ## cached, and for a headless nginx/homepage box you lose nothing.
    ## Drop this line if you later need the camera stack or MIPI DSI displays.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    ## Reduce SD-card wear: build sandboxes and /tmp in RAM.
    boot.tmp.useTmpfs = true;
  };
}
