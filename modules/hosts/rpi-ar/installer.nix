{ self, inputs, ... }: {

  ## A bootstrap/installer image for rpi-ar: same board profile as the real
  ## host, but self-contained on the SD card (boot + root both on SD) and
  ## with a firmware partition big enough to actually hold a Pi 5
  ## kernel+initrd+dtbs — the stock generic aarch64 sd-image defaults to
  ## 30MiB, which isn't enough. Flash this, boot it, partition NVMe/USB SSD,
  ## then nixos-install the real `rpi-ar` flake config onto NVMe with root
  ## from this environment.
  flake.nixosConfigurations.rpi-ar-installer = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ({ modulesPath, pkgs, lib, ... }: {
        imports = [
          (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
        ];
        ## Deliberately NOT importing nixos-hardware's raspberry-pi-5 profile
        ## here: it assumes the generic-extlinux-compatible/no-u-boot boot
        ## chain (that's what the real rpi-ar host uses, via hardware.nix +
        ## nixos-install). This installer image uses the generic aarch64
        ## sd-image's own U-Boot-based chain instead, which already boots
        ## Pi 5 fine on its own — combining both confuses firmware into
        ## pairing the wrong kernel/dtb ("BOOT ERROR: code 7").

        sdImage.firmwareSize = 2048; ## MiB — room for kernel/initrd/dtbs + headroom for later generations

        ## The installer profile pulls in zfs by default for versatility;
        ## it's currently broken against the latest kernel on nixos-unstable
        ## and we don't need it for this bootstrap image anyway.
        boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
          };
        };
        ## Passwordless root at the console, matching how the original
        ## stock hydra sd-image behaved (that one pulls in the "installer"
        ## profile by default; this bare sd-image-aarch64.nix build doesn't).
        services.getty.autologinUser = "root";
        users.users.root = {
          ## Fallback in case the SSH key doesn't match what's actually on
          ## whichever machine you're connecting from — remove once you're
          ## past the bootstrap stage.
          initialPassword = "nixos";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
          ];
        };

        environment.systemPackages = with pkgs; [ git vim rsync parted e2fsprogs ];

        system.stateVersion = "25.11";
      })
    ];
  };
}
