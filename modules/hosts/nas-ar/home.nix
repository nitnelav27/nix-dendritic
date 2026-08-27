{ self, inputs, ... }: {

  flake.homeConfigurations.nasArHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      self.homeModules.vvhNasAr
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhNasAr = { pkgs, ... }: {

    imports = [
      self.homeModules.vvhShell
      self.homeModules.vvhNvf
      self.homeModules.vvhTerminals
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.homePkgsNasAr
    ];

    home = {
      stateVersion = "25.11"; ## DO NOT change this
      sessionVariables = {
        EDITOR = "nvim";
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

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
