{ self, inputs, ... }: {

  flake.nixosModules.nixosVmServices = { pkgs, lib, ...}: {

    ## Boot related stuff
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = [
        "kvm-intel"
      ];
      extraModulePackages = [ ];
      initrd = {
        availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
        ];
        kernelModules = [ ];
      };  
    };

    ## Networking
    networking = {
      hostName = "nixos-vm";
      useDHCP = false;
      dhcpcd.enable = false;
      interfaces.ens18 = {
        ipv4.addresses = [
          {
            address = "10.27.115.3";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = "10.27.115.1";
      nameservers = [
        "10.27.115.1"
      ];
    };

    ## Services
    services = {
      qemuGuest.enable = true;
      openssh = {
        enable = true;
        ports = [ 1186 ];
        settings = {
          PasswordAuthentication = true;
        };
      };
      timesyncd = {
        enable = true;
        servers = [
          "pool.ntp.org"
          "time.google.com"
        ];
      };
    };

    ## Agenix for secrets
    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.system}.default
    ];

    age = {
      secrets = {
        "cloudflare-ddns" = {
          file = self + "/secrets/cloudflare-ddns.age";
          mode = "0400";
        };
        "cloudflare-acme" = {
          file = self + "/secrets/cloudflare-acme.age";
          owner = "acme";
          group = "acme";
          mode = "0400";
        };
      };
    };

  };
}
