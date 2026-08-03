{ self, inputs, ... }: {

  flake.homeConfigurations.utdt10141Home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.homeModules.vvhUtdt10141
      {
        home.username = "vvh";           
        home.homeDirectory = "/home/vvh"; 
      }
    ];
  };

  flake.homeModules.vvhUtdt10141 = { pkgs, ... }: {

    imports = [ 
      self.homeModules.vvhShell
      self.homeModules.vvhNvf
      self.homeModules.vvhTerminals
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.utdt10141HomePkgs
      self.homeModules.vvhVSCode   
      self.homeModules.utdt10141GnomeConfig
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
