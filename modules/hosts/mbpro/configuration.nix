{ self, inputs, ... }: {

  flake.darwinModules.mbproConfig = { config, lib, pkgs, ... }: {

    imports = [
      self.darwinModules.mbproSystem
      self.darwinModules.mbproMounts
      self.darwinModules.mbproHomebrew
      self.darwinModules.mbproStorageOpt
    ];

    nixpkgs.hostPlatform = "aarch64-darwin";
    nixpkgs.config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
    
    nix.settings.experimental-features = "nix-command flakes";

    system.stateVersion = 6;
    networking.hostName = "mbpro";

    environment.systemPackages = with pkgs; [
      mkalias
      vim
      uv
      python314
      home-manager
    ];

    environment.variables = {
      MACOSX_DEPLOYEMENT_TARGET = "26.0.1";
    };

    services.openssh.enable = true;

    users.users.vvh = {
      home = "/Users/vvh";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com"
      ];
    };

    home-manager.users.vvh = self.homeModules.vvhMbpro;
  };
}
