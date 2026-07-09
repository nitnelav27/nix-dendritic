{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPServices = { config, lib, pkgs, ... }:
    let 
      clients = "10.27.115.115/32(insecure,rw,no_subtree_check) 10.27.115.81/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check) 10.27.115.82/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check)";

    in
    {
      boot = {
        supportedFilesystems = [ "nfs" ];
        kernelPackages = pkgs.linuxPackages_latest;
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

      services = {
        openssh = {
          enable = true;
          ports = [ 1186 ];
          settings = {
            PasswordAuthentication = true;
          };
        };
        nfs = {
          settings = {
            nfsd.vers3 = true;
            nfsd.vers4 = true;
            nfsd."vers4.2" = true;
          };
          server = {
            enable = true;
            lockdPort = 4001;
            mountdPort = 4002;
            statdPort = 4000;
            exports = ''
              /export           10.27.115.115/32(insecure,rw,no_subtree_check,fsid=0) 10.27.115.81/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check,fsid=0) 10.27.115.82/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check,fsid=0)
              /export/.decreto  ${clients}
              /export/calibre   ${clients}
              /export/data      ${clients}
              /export/dump      ${clients}
              /export/docs      ${clients}
              /export/results   ${clients}
              /export/migration 10.27.115.115/32(insecure,rw,no_subtree_check)
            '';
          };
        };
        timesyncd.servers = [
          "time.cloudflare.com"
          "pool.ntp.org"
          "time.google.com"
        ];
      };
    };
}
