{ self, inputs, ... }: {

  flakes.nixosModules.nixosVmConfig = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.nixosVmHardware
      self.nixosModules.commonServices
      self.nixosModules.commonConfig
      self.nixosModules.nixosVmServices
    ];

    ## Set timezone
    time.timeZone = "America/Santiago";

    ## Locale
    i18n.defaultLocale = "en_US.UTF-8";

    ## System settings options unique in this host
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      cores = 1;
      max-jobs = 1;
      auto-optimise-store = true;
    };

    ## Main user and main group
    users = {
      groups = {
        vvh = {
          gid = 1000;
        };
      };
      users = {
        vvh = {
          description = "Valentín en NixOS-VM sobre Proxmox";
          isNormalUser = true;
          uid = 1000;
          group = "vvh";
          homeMode = "764";
          #shell = pkgs.zsh;
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

    ## Programs at system level
    programs.zsh.enable = true;

    ## Packages in System profile
    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      rsync
      fastfetch
    ];

    ## DO NOT TOUCH THIS 
    system.stateVersion = "25.11";

  };
}
