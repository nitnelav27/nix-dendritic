{ self, inputs, ... }: {
  flake.homeModules.utdt10141HetznerSync = { config, pkgs, lib, ... }:
    let
      remoteName = "hetzner";
      localDir = "${config.home.homeDirectory}/docs";
      remotePath = "${remoteName}:/home/docs";
      stateDir = "${config.home.homeDirectory}/.local/state/hetzner-sync";
      logFile = "${stateDir}/sync.log";
      rcloneConfPath = "${stateDir}/rclone.conf";
      bisyncCacheDir = "${config.home.homeDirectory}/.cache/rclone/bisync";

      rcloneConfTemplate = pkgs.writeText "hetzner-rclone.conf" ''
        [${remoteName}]
        type = sftp
        ## Delegate the transport to the external ssh client so the sync uses
        ## the exact same Host block (storagebox) as interactive `ssh`.
        ## host/user/port/key settings are ignored by rclone when `ssh` is set.
        ssh = ssh storagebox
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
        runtimeInputs = [ pkgs.rclone pkgs.openssh pkgs.coreutils pkgs.findutils ];
        text = ''
          set -uo pipefail
          mkdir -p "${stateDir}"
          install -m 600 "${rcloneConfTemplate}" "${rcloneConfPath}"
          resync_marker="${stateDir}/.resynced"
          ts() { date -Is; }

          # systemd guarantees only one instance of this oneshot service runs
          # at a time, so any bisync lock file still present when we start is
          # guaranteed stale (left over from a run that was killed -- e.g. by
          # TimeoutStartSec, a network drop, or an interrupted home-manager
          # switch) rather than a real concurrent run. Clear it so bisync's
          # safety check doesn't permanently wedge the job on every future
          # tick until someone notices and deletes it by hand.
          if [ -d "${bisyncCacheDir}" ]; then
            find "${bisyncCacheDir}" -name '*.lck' -delete
          fi

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
              --retries 3 \
              --low-level-retries 10 \
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
