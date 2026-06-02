{ self, inputs, ... }: {

  flake.homeModules.vsvhSSH = { config, lib, pkgs, ... }: {

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          setEnv = {
            TERM = "xterm-256color";
          };
        };
        "macbook" = {
          hostname = "10.27.115.81";
          port = 1186;
          user = "vvh";
          identityFile = "~/.ssh/id_ed25519";
        };
        "macbook-wired" = {
          hostname = "10.27.115.82";
          port = 1186;
          user = "vvh";
          identityFile = "~/.ssh/id_ed25519";
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
        "nixos-vm" = {
          hostname = "10.27.115.3";
          port = 1186;
          user = "vvh";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };

    services.ssh-agent = {
      enable = true;
    };

  };
}
