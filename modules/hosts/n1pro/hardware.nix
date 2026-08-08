{ self, inputs, ... }: {

  flake.nixosModules.n1proHardware = { config, lib, pkgs, modulesPath, ... }: {

    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    ## PLACEHOLDERS -- replace with the real UUIDs from `blkid` /
    ## the hardware-configuration.nix the NixOS installer generates for
    ## this specific box. If Windows is on its own drive (like on nixtop)
    ## you'll only see NixOS's own root + ESP here; if it's sharing one
    ## disk with Windows, "/boot" is very likely the *same* ESP Windows
    ## already created (fat32, ~100-300MB), which commonServices' GRUB
    ## + useOSProber expects to find alongside bootmgfw.efi.
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    # boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    # boot.extraModulePackages = [ ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000"; # TODO: real root UUID
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/0000-0000"; # TODO: real ESP UUID (shared with Windows)
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };

    ## 12GB RAM + a weak N150 -- zram-backed swap buys real headroom without
    ## disk I/O, and modern Gracemont cores handle zstd compression cheaply.
    ## Cheaper than a swapfile on this hardware; drop it if you'd rather use
    ## a plain swap partition/file instead.
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
