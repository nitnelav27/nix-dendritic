{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPNetwork = { config, lib, pkgs, ... }: {

    networking = {
      hostName = "media-ccp";
      networkmanager = {
        enable = true;
        dns = "none";
      };
      useDHCP = false;
      dhcpcd.enable = false;
      interfaces.enp3s0 = {
        ipv4.addresses = [
          {
            address = "10.27.115.4";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = "10.27.115.1";
      nameservers = [
        "10.27.115.1"
      ];
    };
  };
}
