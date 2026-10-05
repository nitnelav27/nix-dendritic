{ self, inputs, ... }: {

  ## Two-way rclone bisync between local NAS dirs and the Hetzner Storage Box.
  ## Runs as a *system* service (User=vvh) using vvh's key file directly, so
  ## it does not depend on an ssh-agent / SSH_AUTH_SOCK being present -- this
  ## is a headless box and nobody is logged in when the timer fires.
  ## The key (~vvh/.ssh/id_ed25519) must be passphrase-less and its .pub
  ## installed on the storage box.
  ##
  ## First run after rebuild (does --resync per pair):
  ##   sudo systemctl start hetzner-sync
  ##   journalctl -u hetzner-sync -f
  flake.nixosModules.mediaCCPHetznerSync = { config, lib, pkgs, ... }:
    let
      user = "vvh";
      group = "vvh";
      remoteName = "hetzner";
      sbUser = "u664914";
      sbHost = "${sbUser}.your-storagebox.de";
      stateDir = "/var/lib/hetzner-sync";
      keyFile = "/home/${user}/.ssh/id_ed25519";
      knownHosts = "${stateDir}/known_hosts";

      ## local path -> remote path (on the storage box)
      pairs = {
        "/storage/nas/docs"    = "/home/docs";
        "/storage/nas/data"    = "/home/data";
        "/storage/nas/results" = "/home/results";
      };

      rcloneConf = pkgs.writeText "hetzner-rclone.conf" ''
        [${remoteName}]
        type = sftp
        host = ${sbHost}
        user = ${sbUser}
        port = 23
        key_file = ${keyFile}
        known_hosts_file = ${knownHosts}
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
        ._*
        .git/**
        lost+found/**
      '';

      pairList = lib.concatMapStringsSep " " lib.escapeShellArg
        (lib.mapAttrsToList (l: r: "${l}|${r}") pairs);

      syncScript = pkgs.writeShellApplication {
        name = "hetzner-sync";
        runtimeInputs = [ pkgs.rclone pkgs.coreutils pkgs.openssh ];
        text = ''
          set -uo pipefail
          umask 077
          cd "${stateDir}" || exit 1

          if [ ! -r "${keyFile}" ]; then
            echo "SSH key ${keyFile} missing or unreadable" >&2
            exit 1
          fi
          ## Pin the storage box host key (TOFU on first run)
          if [ ! -s "${knownHosts}" ]; then
            ssh-keyscan -p 23 -t ed25519,rsa "${sbHost}" > "${knownHosts}"
          fi

          rc() { rclone --config "${rcloneConf}" "$@"; }

          failed=0
          for pair in ${pairList}; do
            local_dir=''${pair%%|*}
            remote=''${pair#*|}
            name=$(basename "$local_dir")
            marker="${stateDir}/.resynced-$name"
            extra=()

            if [ ! -d "$local_dir" ]; then
              echo "[$name] local dir $local_dir missing, skipping"
              failed=1; continue
            fi

            if [ ! -f "$marker" ]; then
              echo "[$name] first run: creating remote dir and doing --resync"
              rc mkdir "${remoteName}:$remote" || { failed=1; continue; }
              extra+=(--resync)
            fi

            echo "[$name] bisync $local_dir <-> ${remoteName}:$remote"
            if rc bisync "$local_dir" "${remoteName}:$remote" \
                --workdir "${stateDir}/bisync" \
                --exclude-from "${excludeFile}" \
                --compare size,modtime \
                --conflict-resolve newer \
                --conflict-suffix conflict \
                --max-delete 10 \
                --resilient \
                --recover \
                "''${extra[@]}"; then
              touch "$marker"
              echo "[$name] OK"
            else
              status=$?
              echo "[$name] FAILED (exit $status)"
              failed=1
            fi
          done

          exit "$failed"
        '';
      };
    in
    {
      environment.systemPackages = [ pkgs.rclone syncScript ];

      systemd.services.hetzner-sync = {
        description = "Bisync NAS dirs with Hetzner Storage Box";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        unitConfig.RequiresMountsFor = builtins.attrNames pairs;
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          User = user;
          Group = group;
          StateDirectory = "hetzner-sync";
          StateDirectoryMode = "0700";
          ## Initial --resync of data/results can take a long time
          TimeoutStartSec = "6h";
          Nice = 10;
          IOSchedulingClass = "idle";
          ExecStart = "${syncScript}/bin/hetzner-sync";
        };
      };

      systemd.timers.hetzner-sync = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 01:00:00";  ## daily at 1 AM (America/Santiago)
          Persistent = true;
        };
      };
    };
}
