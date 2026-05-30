{ self, inputs, ... }: {

  flake.homeConfigurations.vvh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs.legacyPackages."x86_64-linux";

    modules = [
      self.homeModules.vvhNixosVm
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhNixosVm = { pkgs, ... }: {
    
    imports = [
      self.homeModules.vvhShell
      self.homeModules.vvhNvf
      self.homeModules.vvhTerminals
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.homePkgsNixosVm
    ];

    home = {
      stateVersion = "25.05";
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      file = {
        figlet-fonts = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/figlet_fonts";
          target = ".config/figlet_fonts";
        };
      };
    };

    programs.home-manager.enable = true;
  };
}
