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
        device = "/dev/disk/by-uuid/d74e2316-7884-4e68-a286-07c40761cdb6"; 
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/E217-1641"; 
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      "/home" = {
        device = "/dev/disk/by-uuid/5fe18cb9-b61d-40e1-8c9e-d69fb2e48920";
        fsType = "ext4";
      };
    };

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
