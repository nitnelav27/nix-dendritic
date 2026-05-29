{ self, inputs, ... }: {

  flake.homeModules.homePkgsNixosVm = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      acl
      dnslookup
    ];
  };
}
