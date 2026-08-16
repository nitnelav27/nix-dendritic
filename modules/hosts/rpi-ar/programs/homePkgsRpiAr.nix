{ self, inputs, ... }: {

  flake.homeModules.homePkgsRpiAr = { pkgs, ... }: {
    home.packages = with pkgs; [
      acl
      dnslookup
    ];
  };
}
