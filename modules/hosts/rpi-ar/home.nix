{ self, inputs, ... }: {

  flake.homeConfigurations.rpiArHome = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
    modules = [
      self.homeModules.vvhRpiAr
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhRpiAr = { pkgs, ... }: {
    imports = [
      self.homeModules.vvhShell
      self.homeModules.vvhGit
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.homePkgsRpiAr
    ];

    home = {
      stateVersion = "25.05";
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      enableNixpkgsReleaseCheck = false;
    };

    programs.home-manager.enable = true;
  };
}
