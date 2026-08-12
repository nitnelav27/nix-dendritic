{ self, inputs, ... }: {

  flake.homeConfigurations.utdt10141Home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true; 
    };
    
    extraSpecialArgs = { hostname = "utdt10141"; };

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
      self.homeModules.utdt10141Solaar
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
        CHROME_DEVEL_SANDBOX = "/usr/local/bin/chrome-sandbox";
      };
      file = {
        # doom = {
        #   enable = true;
        #   executable = false;
        #   recursive = true;
        #   source = self + "/extra/doom";
        #   target = ".config/doom";
        # };
        matplotlib = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/matplotlib";
          target = ".config/matplotlib";
        };
        # jupyter = {
        #   enable = true;
        #   executable = false;
        #   recursive = true;
        #   source = self + "/extra/jupyter";
        #   target = ".config/jupyter";
        # };
        # scripts = {
        #   enable = true;
        #   executable = true;
        #   recursive = true;
        #   source = self + "/extra/scripts";
        #   target = ".config/scripts";
        # };
        figlet-fonts = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/figlet_fonts";
          target = ".config/figlet_fonts";
        }; 
      };
      ## Silence warning about home-manager and nixpkgs mismatch
      enableNixpkgsReleaseCheck = false;
    };

    programs.home-manager.enable = true;
  };
}
