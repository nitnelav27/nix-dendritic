{ self, inputs, ... }: {

  flake.nixosModules.rpiCCPServices = { pkgs, lib, ...}: {

    ## Boot: the Pi 5 firmware loads the kernel directly per generation
    ## (boot.loader.raspberry-pi.bootloader = "kernel" in hardware.nix).
    ## There is no GRUB and no EFI here, so this host must NOT import
    ## self.nixosModules.commonServices (which forces GRUB on).
    boot = {
      loader.raspberry-pi.configurationLimit = 5;
      kernelModules = [ ];
      extraModulePackages = [ ];
      ## initrd modules are supplied by the raspberry-pi-5 profile.
    };

    ## Networking
    networking = {
      hostName = "rpi-ccp";
      useDHCP = false;
      dhcpcd.enable = false;
      interfaces.end0 = {
        ipv4.addresses = [
          {
            address = "10.27.115.3";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = "10.27.115.1";
      nameservers = [ "10.27.115.1" ];
    };

    ## Services
    services = {
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
      resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

    ## Agenix for secrets
    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
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
