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
    ## Without this, extra-substituters declared via a flake's `nixConfig`
    ## (e.g. nixos-raspberrypi's cachix cache) get silently ignored -- Nix
    ## refuses to trust a substituter suggested by an untrusted user, so
    ## every build falls through to compiling from source instead of
    ## downloading the prebuilt kernel/packages.
    nix.settings.trusted-users = [ "root" "vvh" ];

    ## Local aarch64-linux builder VM, used to build things like the rpi-ar
    ## installer sd-image without needing a remote/emulated builder.
    nix.linux-builder.enable = true;

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

    services.openssh = {
      enable = true;
      extraConfig = ''
        Port 1186
      '';
    };

    users.users.vvh = {
      home = "/Users/vvh";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com"
      ];
    };

    home-manager.users.vvh = self.homeModules.vvhMbpro;
    home-manager.extraSpecialArgs = { hostname = config.networking.hostName; };
  };
}
