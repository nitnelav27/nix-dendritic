{ self, inputs, ... }: {

  flake.homeModules.homePkgsNasAr = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      acl
      dnslookup
    ];
  };
}
