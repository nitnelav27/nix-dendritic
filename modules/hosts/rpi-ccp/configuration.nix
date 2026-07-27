{ self, inputs, ... }: {

  flake.nixosModules.rpiCCPConfig = { pkgs, lib, ... }: {
    imports = [
      inputs.agenix.nixosModules.default
      self.nixosModules.rpiCCPHardware
      self.nixosModules.commonConfig
      self.nixosModules.rpiCCPServices
      self.nixosModules.rpiCCPFirewall
      self.nixosModules.vvhNginx
      self.nixosModules.vvhHomepage
    ];

    ## Set timezone
    time.timeZone = "America/Santiago";

    ## Locale
    i18n.defaultLocale = "en_US.UTF-8";

    ## System settings options unique in this host
    nix.settings = { 
      cores = 2;
      max-jobs = 2;
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
          description = "Valentín en Raspberry Pi 5 Concepción";
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

    home-manager.users.vvh = self.homeModules.vvhRpiCCP;

    ## Programs at system level
    programs = {
      zsh.enable = true;
      ssh.startAgent = true;
    };

    ## Packages in System profile
    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      rsync
      fastfetch
      libraspberrypi
      raspberrypi-eeprom
    ];

    ## DO NOT TOUCH THIS 
    system.stateVersion = "25.11";

  };
}
