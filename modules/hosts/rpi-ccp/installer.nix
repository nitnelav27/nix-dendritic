{ self, inputs, ... }: {

  ## Bootstrap/installer image for rpi-ccp: same board profile + "kernel"
  ## bootloader as the real host, self-contained on the SD card, used to
  ## repartition/format the NVMe drive from scratch and nixos-install the
  ## real rpi-ccp config onto it.
  ##
  ## Build (from mbpro, via the linux-builder VM):
  ##   nix build .#nixosConfigurations.rpi-ccp-installer.config.system.build.sdImage -L
  flake.nixosConfigurations.rpi-ccp-installer = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
      inputs.nixos-raspberrypi.nixosModules.sd-image
      ({ pkgs, lib, ... }: {
        boot.loader.raspberry-pi.bootloader = "kernel";

        networking.hostName = "rpi-ccp-installer";

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
          };
        };
        services.getty.autologinUser = "root";

        users.users.root = {
          initialPassword = "nixos";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
          ];
        };

        environment.systemPackages = with pkgs; [
          git
          vim
          rsync
          parted
          e2fsprogs
        ];

        system.stateVersion = "25.11";
      })
    ];
  };
}
