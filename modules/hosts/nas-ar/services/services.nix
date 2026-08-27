{ self, inputs, ... }: {

  flake.nixosModules.nasArServices = { pkgs, lib, ... }: {

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      ## nfsd must be loaded via systemd-modules-load at boot rather than
      ## relying on nfs-server.service's runtime `modprobe nfsd` -- that
      ## runtime modprobe silently fails under systemd's sandboxed PATH and
      ## breaks lockd (NFSv3 locking). See project memory: nfs_mounts_rpi_ar.
      kernelModules = [ "nfsd" ];
      supportedFilesystems = [ "nfs" ];
    };

    networking = {
      hostName = "nas-ar";
      useDHCP = false;
      dhcpcd.enable = false;
      ## TODO: set this to the machine's real interface name (check with
      ## `ip link` on the installer; commonly enp*/eth0 for a wired NIC).
      interfaces.enp1s0 = {
        ipv4.addresses = [
          {
            address = "10.27.81.4";
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
        settings = {
          PasswordAuthentication = true;
        };
      };
      timesyncd = {
        enable = true;
        servers = [
          "time.cloudflare.com"
          "pool.ntp.org"
          "time.google.com"
        ];
      };
      resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [ "1.1.1.1" "8.8.8.8" ];
      };
    };
  };
}
