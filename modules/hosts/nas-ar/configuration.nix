{ self, inputs, ... }: {

  flake.nixosModules.nasArConfig = { config, lib, pkgs, ... }: {

    imports = [
      inputs.agenix.nixosModules.default
      self.nixosModules.nasArHardware
      self.nixosModules.commonServices
      self.nixosModules.commonConfig
      self.nixosModules.nasArServices
      self.nixosModules.nasArFirewall
      #self.nixosModules.nasArMounts
      self.nixosModules.nasArSamba
      self.nixosModules.nasArNfs
      self.nixosModules.nasArGithubToken
    ];

    time.timeZone = "America/Argentina/Buenos_Aires";
    i18n.defaultLocale = "en_US.UTF-8";

    users = {
      groups = {
        vvh = {
          gid = 1000;
        };
      };

      users = {
        vvh = {
          description = "NixOS NAS host, Argentina";
          isNormalUser = true;
          uid = 1000;
          group = "vvh";
          homeMode = "764";
          shell = pkgs.zsh;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
          ];
        };
      };
    };

    programs = {
      zsh.enable = true;
      ssh.startAgent = true;
    };

    home-manager.users.vvh = self.homeModules.vvhNasAr;

    ## Packages in System profile
    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      rsync
      fastfetch
      acl
      nfs-utils
    ];

    ## DO NOT TOUCH THIS
    system.stateVersion = "25.11";

  };
}
