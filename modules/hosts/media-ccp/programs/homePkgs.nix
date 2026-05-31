{ self, inputs, ... }: {

  flake.homeModules.mediaCCPHomePkgs = { config, lib, pkgs, ... }: {

    home.packages = with pkgs; [
        cuetools
        shntool
        flac
        xsel
    ];
  };
}
