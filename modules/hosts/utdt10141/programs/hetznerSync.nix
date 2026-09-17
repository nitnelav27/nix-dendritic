{ self, inputs, ... }: {
  flake.homeModules.utdt10141HetznerSync = { config, pkgs, lib, ... }:
    let
      remoteName = "hetzner";
      localDir = "${config.home.homeDirectory}/docs";
      remotePath = "${remoteName}:/home/docs";
      stateDir = "${config.home.homeDirectory}/.local/state/hetzner-sync";
      logFile = "${stateDir}/sync.log";
      rcloneConfPath = "${stateDir}/rclone.conf";

      rcloneConfTemplate = pkgs.writeText "hetzner-rclone.conf" ''
        [${remoteName}]
        type = sftp
        host = u664914.your-storagebox.de
        user = u664914
        port = 23
        key_use_agent = true
        shell_type = unix
      '';

      excludeFile = pkgs.writeText "hetzner-sync-excludes" ''
        *.aux
        *.bbl
        *.bcf
        *.blg
        *.fdb_latexmk
        *.fls
        *.log
        *.nav
        *.out
        *.run.xml
        *.snm
        *.synctex.gz
        *.toc
        *.vrb
        .DS_Store
        .git/**
      '';

      syncScript = pkgs.writeShellApplication {
        name = "hetzner-sync";
        runtimeInputs = [ pkgs.rclone pkgs.coreutils ];
        text = ''
          set -uo pipefail
          mkdir -p "${stateDir}"
          install -m 600 "${rcloneConfTemplate}" "${rcloneConfPath}"
          resync_marker="${stateDir}/.resynced"
          ts() { date -Is; }

          extra_args=()
          if [ ! -f "$resync_marker" ]; then
            extra_args+=(--resync)
          fi

          if rclone --config "${rcloneConfPath}" bisync "${localDir}" "${remotePath}" \
              --exclude-from "${excludeFile}" \
              --conflict-resolve newer \
              --conflict-suffix conflict \
              --max-delete 10 \
              --recover \
              --compare size,modtime,checksum \
              --resilient \
              "''${extra_args[@]}" >> "${logFile}" 2>&1; then
            touch "$resync_marker"
            echo "$(ts) SUCCESS" >> "${logFile}"
          else
            status=$?
            echo "$(ts) FAILURE (exit $status)" >> "${logFile}"
            exit "$status"
          fi
        '';
      };
    in
    {
      home.packages = [ syncScript ];

      systemd.user.services.hetzner-sync = {
        Unit = {
          Description = "Bisync ~/docs with Hetzner Storage Box";
          X-RestartIfChanged = false;
        };
        Service = {
          Type = "oneshot";
          TimeoutStartSec = "10m";
          ExecStart = "${syncScript}/bin/hetzner-sync";
        };
      };

      systemd.user.timers.hetzner-sync = {
        Unit.Description = "Hourly Hetzner Storage Box sync";
        Timer = {
          OnCalendar = "hourly";
          Persistent = true;
          RandomizedDelaySec = 60;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
