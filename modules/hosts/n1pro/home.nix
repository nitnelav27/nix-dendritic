{ self, inputs, ... }: {

  flake.homeConfigurations.n1proHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.homeModules.cosmeN1pro
      {
        home.username = "cosme";           # <- set to your actual account name on the work box
        home.homeDirectory = "/home/cosme"; # <- match the line above
      }
    ];
  };

  flake.homeModules.cosmeN1pro = { pkgs, ... }: {

    imports = [ 
      self.homeModules.vvhShell
      self.homeModules.vvhNvf
      self.homeModules.vvhTerminals
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.N1proHomePkgs
      self.homeModules.vvhVSCode   # uncomment to bring your VS Code profile over too
    ];

    targets.genericLinux = {
      enable = true;
      nixGL.packages = inputs.nixgl.packages;
    };

    home = {
      stateVersion = "25.05";
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      ## Silence warning about home-manager and nixpkgs mismatch
      enableNixpkgsReleaseCheck = false;
    };

    programs.home-manager.enable = true;
  };
}
