{ self, inputs, ... }: {

  flake.homeModules.vvhSSH = { config, lib, pkgs, ... }: {

    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      controlMaster = "auto";
      controlPersist = "10m";
      matchBlocks = {
        "*" = {
          setEnv = {
            TERM = "xterm-256color";
          };
        };
        "github.com" = {
          port = 22;
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_ed25519";
        };
        "media-ccp" = {
          hostname = "10.27.115.4";
          port = 1186;
          user = "vvh";
          identityFile = "~/.ssh/id_ed25519";
        }; 
        "nixtop" = {
          hostname = "10.27.115.115";
          port = 1186;
          user = "vsvh";
          identityFile = "~/.ssh/id_ed25519";
        };
        "nixos-vm" = {
          hostname = "10.27.115.3";
          port = 1186;
          user = "vvh";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}
