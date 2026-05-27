{ self, inputs, ... }: {

  flake.homeConfigurations.vvh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
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
    ];

    home = {
      stateVersion = "25.05";
      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
    };

    programs.home-manager.enable = true;
  };
}
