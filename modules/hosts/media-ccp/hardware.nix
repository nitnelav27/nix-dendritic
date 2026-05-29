{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPHardware = { config, lib, pkgs, modulesPath, ... }: {

    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    # boot.initrd.kernelModules = [ ];
    # boot.kernelModules = [ "kvm-intel" ];
    # boot.extraModulePackages = [ ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/f72588ab-09c3-4072-8071-fe343eb502f7";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/F6D6-7015";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      "/home" = {
        device = "/dev/disk/by-uuid/d5cb2c58-de89-4dd1-9b3e-c0de7a60785e";
        fsType = "ext4";
      };
    };

    swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    # networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  
}
