{ self, inputs, ... }: {

  flake.darwinModules.mbproMounts = { config, lib, pkgs, ... }:
    let
      serverIP = "10.27.115.4";
      nfsMount = name: remotePath: mountPoint: {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            ''
            until /sbin/ping -c 1 -t 5 ${serverIP}; do sleep 5; done
            /sbin/mount | grep -q "${mountPoint}" || \
            /sbin/mount_nfs -o resvport,soft,bg,tcp,noatime,intr,nfsvers=3,noowners ${serverIP}:${remotePath} ${mountPoint}
            ''
          ];
          RunAtLoad = true;
          StandardErrorPath = "/var/log/mount-${name}.err.log";
          StandardOutPath = "/var/log/mount-${name}.out.log";
          StartInterval = 50;
        };
      };
    in {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        echo "Creating NFS mount points..."
        mkdir -p /Users/vvh/{.decreto,dump,docs}
        mkdir -p /Users/vvh/nas/{calibre,data,results}
        chown -R vvh:staff /Users/vvh/nas
      '';

      launchd.daemons = {
        decreto-share = nfsMount "decreto" "/export/.decreto" "/Users/vvh/.decreto";
        dump-share    = nfsMount "dump"    "/export/dump"     "/Users/vvh/dump";
        docs-share    = nfsMount "docs"    "/export/docs"     "/Users/vvh/docs";
        calibre-share = nfsMount "calibre" "/export/calibre"  "/Users/vvh/nas/calibre";
        data-share    = nfsMount "data"    "/export/data"     "/Users/vvh/nas/data";
        results-share = nfsMount "results" "/export/results"  "/Users/vvh/nas/results";
      };
    };
}
