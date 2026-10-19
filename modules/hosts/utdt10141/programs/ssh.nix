{ self, inputs, ... }: {

  flake.homeModules.utdt10141SSH = { config, lib, pkgs, ... }: {

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      ## Pre-existing, hand-written entries (moved out of ~/.ssh/config so
      ## Home Manager can own that file) keep working from here.
      includes = [ "~/.ssh/config.local" ];
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
        };
        ## Hetzner Storage Box. Port 23 = SSH (restricted shell, rsync, borg,
        ## SFTP); port 22 is SFTP/SCP only. Also used by rclone via `ssh =`.
        "storagebox" = {
          hostname = "u664914.your-storagebox.de";
          port = 23;
          user = "u664914";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
          ## Detect dead links (VPN flaps, suspend) instead of hanging bisync.
          serverAliveInterval = 30;
          serverAliveCountMax = 4;
        };
      };
    };
  };
}
