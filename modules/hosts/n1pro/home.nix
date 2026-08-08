{ self, inputs, ... }: {

  flake.homeConfigurations.vvh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      self.homeModules.vvhN1pro
      {
        home.username = "vvh";
        home.homeDirectory = "/home/vvh";
      }
    ];
  };

  flake.homeModules.vvhN1pro = { pkgs, ... }: {

    imports = [
      self.homeModules.vvhShell
      self.homeModules.vvhTerminals
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.vvhGit
      self.homeModules.vvhYazi
      self.homeModules.vvhRofi
      self.homeModules.vvhMediaPlayers
      self.homeModules.vvhSway
      self.homeModules.n1proHomePkgs
      # self.homeModules.vvhVSCode      # uncomment if you end up doing dev work on this box
    ];

    home = {
      stateVersion = "26.05"; ## first release this host was installed with -- do not change later
      sessionVariables = {
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        EDITOR = "nvim";
        VISUAL = "nvim";
        TERMINAL = "ghostty";
        BROWSER = "firefox";
        PAGER = "less";
        SHELL = "${pkgs.zsh}/bin/zsh";
      };
      ## Silence warning about home-manager and nixpkgs mismatch
      enableNixpkgsReleaseCheck = false;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
