{ self, inputs, ... }: {

  flake.homeConfigurations.rpiCCPHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;

    modules = [
      self.homeModules.vvhRpiCCP
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhRpiCCP = { pkgs, ... }: {
    
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
      ## Silence warning about home-manager and nixpkgs missmatch
      enableNixpkgsReleaseCheck = false;
    };

    programs.home-manager.enable = true;
  };
}
