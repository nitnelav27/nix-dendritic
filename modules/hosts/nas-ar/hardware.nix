{ self, inputs, ... }: {

  ## After booting the target machine from the NixOS installer ISO and
  ## partitioning/formatting its disks, run:
  ##   nixos-generate-config --root /mnt
  ## and copy the resulting `fileSystems`, `swapDevices`, `boot.initrd.*`
  ## and `boot.kernelModules` values from /mnt/etc/nixos/hardware-configuration.nix
  ## into this file (translating plain `{ ... }` NixOS module syntax into the
  ## `flake.nixosModules.nasArHardware = { ... }: { ... }` shape below).
  flake.nixosModules.nasArHardware = { config, lib, pkgs, modulesPath, ... }: {

    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    ## TODO: fill these in from hardware-configuration.nix after install.
    # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    # boot.initrd.kernelModules = [ ];
    # boot.kernelModules = [ ];
    # boot.extraModulePackages = [ ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/7e7d3be2-a04d-4929-91a7-f581eac333e6";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/1CC0-23D8";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      }; 
      "/home" = {
        device = "/dev/disk/by-uuid/456120f5-86c4-4118-a58c-42697329d31e";
        fsType = "ext4";
      };
      ## /storage was a single ext4 disk (piExternal) until TORR + piExternal
      ## were combined into one LVM volume group ("storage-vg") to pool their
      ## capacity. See modules/hosts/nas-ar/services/mounts.nix.
      "/storage" = {
        device = "/dev/storage-vg/storage-lv";
        fsType = "ext4";
      };
    };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
