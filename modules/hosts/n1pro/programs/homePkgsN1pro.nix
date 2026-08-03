{ self, inputs, ... }: {

  flake.homeModules.N1proHomePkgs = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      fastfetch
      cowsay
      sl
    ];
  };
}
