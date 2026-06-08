{ self, inputs, ... }: {

  flake.homeModules.vvhMbpro = { pkgs, ... }: {

    imports = [
      inputs.mac-app-util.homeManagerModules.default
      self.homeModules.vvhShell
      self.homeModules.vvhTerminals
      self.homeModules.vvhNvf
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.mbproHomePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.vvhMediaPlayers
      self.homeModules.vvhVSCode
      self.homeModules.vvhSSH
    ];

    home = {
      username = "vvh";
      homeDirectory = "/Users/vvh";
      stateVersion = "24.11";
      enableNixpkgsReleaseCheck = false;

      sessionVariables = {
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        DOOMDIR = "$HOME/.config/doom";
        IPYTHONDIR = "$HOME/.config/ipython";
        PYRIGHT_PYTHON_FORCE_VERSION = "3.14";
        JUPYTER_CONFIG_DIR = "$HOME/.config/jupyter";
        EDITOR = "nvim";
        VISUAL = "nvim";
        TERMINAL = "ghostty";
        VIDEO = "mpv";
        OPENER = "open";
        PAGER = "less";
        BROWSER = "firefox";
      };

      file = {
        doom = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/doom";
          target = ".config/doom";
        };
        matplotlib = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/matplotlib";
          target = ".config/matplotlib";
        };
        jupyter = {
          enable = true;
          executable = false;
          recursive = true;
          source = self + "/extra/jupyter";
          target = ".config/jupyter";
        };
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

    programs.home-manager.enable = true;
  };
}
