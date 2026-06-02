{ self, inputs, ... }: {

  flake.homeConfigurations.nixtopHome = inputs.home-manager.lib.homeManagerConfiguration {
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
        # ../../modules/common/terminals.nix 
        # ../../modules/common/myshell.nix
        # ./localModules/gnomeHomeConfig.nix
        # ../../modules/wm/hyprland.nix
        # ../../modules/wm/hyprlock.nix
        # ../../modules/common/homeBase.nix
        # ./localModules/homePkgs.nix
        # ./localModules/homeServices.nix
        # ../../modules/common/neovim.nix
        # ../../modules/common/git.nix
        # ../../modules/media/mpv.nix
        # ../../modules/wm/rofi.nix
        # ../../modules/utils/vscode.nix 
        # ./localModules/ssh.nix 
        # ../../modules/common/yazi.nix
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

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
