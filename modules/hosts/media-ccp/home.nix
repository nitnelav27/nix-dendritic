{ self, inputs, ... }: {

  flake.homeConfigurations.vvh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      self.homeModules.vvhMediaCCP
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhMediaCCP = { pkgs, ... }: {

    imports = [
      # ../../modules/common/myshell.nix
      # ../../modules/common/neovim.nix
      # ../../modules/common/git.nix
      # ../../modules/common/homeBase.nix
      # ./localModules/homePkgs.nix
      # ../../modules/common/yazi.nix
    ];

    home = {
      stateVersion = "24.11"; ## DO NOT change this
      sessionVariables = {
        EDITOR = "nvim";
      };
      file = {
        scripts = {
          enable = true;
          executable = true;
          recursive = true;
          source = self + "/extra/scripts";
          target = ".config/scripts";        
        };
        figlet-fonts = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/figlet_fonts";
          target = ".config/figlet_fonts";
        };
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
