{ self, inputs, ... }: {

  flake.nixosModules.rpiArNfs = { config, lib, pkgs, ... }:
    let
      clients = "10.27.81.81/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check) 10.27.81.82/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check)";
    in
    {
      services.nfs = {
        settings = {
          nfsd.vers3 = true;
          nfsd.vers4 = true;
          nfsd."vers4.2" = true;
        };
        server = {
          enable = true;
          lockdPort = 4001;
          mountdPort = 4002;
          statdPort = 4000;
          exports = ''
            /export          10.27.81.81/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check,fsid=0) 10.27.81.82/32(insecure,rw,sync,all_squash,anonuid=1000,anongid=1000,no_subtree_check,fsid=0)
            /export/.decreto   ${clients}
            /export/data  ${clients}
            /export/docs  ${clients}
            /export/dump  ${clients}
            /export/results  ${clients}
            /export/calibre  ${clients}
          '';
        };
      };
    };
}
