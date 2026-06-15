{ self, inputs, ... }: {

  flake.nixosModules.mediaCCPQbittorrent = { config, lib, pkgs, ... }: {
    
    services.qbittorrent = {
      enable = true;
      package = pkgs.qbittorrent-nox;
      user = "vvh";
      group = "vvh";
      openFirewall = true;
      profileDir = "/home/vvh/appData";
      webuiPort = 8080;
      extraArgs = [ "--confirm-legal-notice" ];
    };

    systemd.services.qbittorrent.serviceConfig = {
      # Use mkForce to override the default "yes" from the NixOS module
      ProtectHome = lib.mkForce false;
      WorkingDirectory = "/home/vvh/appData/qBittorrent";
      Environment = "QT_QPA_PLATFORM=offscreen";

      # Allow torrent file uploads via the web UI (they land in /tmp first)
      PrivateTmp = lib.mkForce false;

      # If uploads still fail, also relax these:
      ReadWritePaths = [ "/home/vvh/appData" "/tmp" ];
    };
  };
}
