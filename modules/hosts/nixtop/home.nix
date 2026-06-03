{ self, inputs, ... }: {

  flake.homeConfigurations.vsvh = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      self.homeModules.vsvhNixtop
      {
        home.username = "vsvh";
        home.homeDirectory = "/home/vsvh";
      }
    ];
  };

  flake.homeModules.vsvhNixtop = { config, pkgs, lib, ... }: {

    imports = [
      self.homeModules.vvhShell
      self.homeModules.vvhTerminals
      self.homeModules.vvhNvf
      self.homeModules.vvhHomeBasePkgs
      self.homeModules.nixtopHomePkgs
      self.homeModules.vvhYazi
      self.homeModules.vvhGit
      self.homeModules.vvhMediaPlayers
      self.homeModules.vvhRofi
      self.homeModules.vvhVSCode
      self.homeModules.nixtopGnomeHomeConfig
      self.homeModules.vsvhSSH
      self.homeModules.vvhHyprland
      self.homeModules.vvhHyprlock
      self.homeModules.vvhHypridle
    ];
    
    home = {
      stateVersion = "24.11"; ## DO NOT change this
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        NIXOS_OZONE_WL = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        DOOMDIR = "$HOME/.config/doom";
        IPYTHONDIR = "$HOME/.config/ipython";
        JUPYTER_CONFIG_DIR = "$HOME/.config/jupyter";
        EDITOR = "nvim";
        READER = "zathura";
        VISUAL = "nvim";
        TERMINAL = "ghostty";
        VIDEO = "mpv";
        OPENER = "xdg-open";
        PAGER = "less";
        BROWSER = "firefox";
        NASDATA = "$HOME/nas/data";
        NASRES = "$HOME/nas/results";
        SHELL = "${pkgs.zsh}/bin/zsh";
        STARSHIP_LOG = "error";
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
      ## Silence warning about home-manager and nixpkgs missmatch
      enableNixpkgsReleaseCheck = false;
    };

    ### Home Services
    services = {
      cliphist = {
        enable = true;
        extraOptions = [
          "-max-items" "1000"
          "-max-dedupe-search" "20"
        ];
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
