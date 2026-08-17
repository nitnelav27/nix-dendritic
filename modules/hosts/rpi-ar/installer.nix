{ self, inputs, ... }: {

  ## Bootstrap/installer image for rpi-ar: same board profile + "kernel"
  ## bootloader as the real host, but self-contained on the SD card (root and
  ## firmware both on the SD, like the stock bootstrap image) so it can
  ## partition/format NVMe root+home and the USB SSD from scratch, then
  ## nixos-install the real rpi-ar config onto them.
  ##
  ## Build (from mbpro, via the linux-builder VM):
  ##   nix build .#nixosConfigurations.rpi-ar-installer.config.system.build.sdImage -L
  flake.nixosConfigurations.rpi-ar-installer = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
      inputs.nixos-raspberrypi.nixosModules.sd-image
      ({ pkgs, lib, ... }: {
        boot.loader.raspberry-pi.bootloader = "kernel";

        networking.hostName = "rpi-ar-installer";

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
          };
        };
        ## Passwordless root at the console, matching how the original stock
        ## hydra sd-image behaved.
        services.getty.autologinUser = "root";

        users.users.root = {
          ## Fallback in case the SSH key doesn't match what's actually on
          ## whichever machine you're connecting from -- remove once you're
          ## past the bootstrap stage.
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
