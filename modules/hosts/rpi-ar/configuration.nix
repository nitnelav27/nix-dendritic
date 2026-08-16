{ self, inputs, ... }: {

  flake.nixosModules.rpiArConfig = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.rpiArHardware
      self.nixosModules.commonConfig
      self.nixosModules.rpiArServices
      self.nixosModules.rpiArFirewall
      self.nixosModules.rpiArMounts
      self.nixosModules.rpiArNfs
    ];

    time.timeZone = "America/Argentina/Buenos_Aires";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings = {
      cores = 2;
      max-jobs = 2;
    };

    users = {
      groups.vvh.gid = 1000;
      users.vvh = {
        description = "Valentín en Raspberry Pi 5 Argentina";
        isNormalUser = true;
        uid = 1000;
        group = "vvh";
        homeMode = "764";
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
        ];
      };
    };

    home-manager.users.vvh = self.homeModules.vvhRpiAr;

    programs = {
      zsh.enable = true;
      ssh.startAgent = true;
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      rsync
      fastfetch
      acl
      libraspberrypi
      raspberrypi-eeprom
      nfs-utils
    ];

    ## DO NOT TOUCH THIS
    system.stateVersion = "25.11";
  };
}
