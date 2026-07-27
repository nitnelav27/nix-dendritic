{ self, inputs, ... }: {

  flake.homeModules.homePkgsRpiCCP = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      acl
      dnslookup
    ];
  };
}
