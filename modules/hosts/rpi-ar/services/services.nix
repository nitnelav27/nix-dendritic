{ self, inputs, ... }: {

  flake.nixosModules.rpiArServices = { pkgs, lib, ... }: {

    boot = {
      loader.generic-extlinux-compatible.configurationLimit = 5;
      kernelModules = [ ];
      extraModulePackages = [ ];
      supportedFilesystems = [ "nfs" ];
    };

    networking = {
      hostName = "rpi-ar";
      useDHCP = false;
      dhcpcd.enable = false;
      interfaces.end0 = {
        ipv4.addresses = [
          {
            address = "10.27.81.3";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = "10.27.81.1";      
      nameservers = [ "10.27.81.1" ];     
    };

    services = {
      openssh = {
        enable = true;
        ports = [ 1186 ];                 
        settings.PasswordAuthentication = true;
      };
      timesyncd = {
        enable = true;
        servers = [ "pool.ntp.org" "time.google.com" ];
      };
      resolved = {
        enable = true;
        fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
      };
    };
  };
}
