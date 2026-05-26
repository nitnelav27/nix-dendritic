{ self, inputs, ... }: {

  flake.nixosModules.commonServices = { pkgs, lib, ...}: {
    boot = {
      loader = {
        systemd-boot.enable = false;
        efi = {
          canTouchEfiVariables = false;
          efiSysMountPoint = "/boot";
        };
        grub = {
          enable = true;
          efiSupport = true;
          efiInstallAsRemovable = true;
          device = "nodev";
        };
      };
    };
  };
}
