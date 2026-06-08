{ self, inputs, ... }: {

  flake.homeModules.mbproHomePkgs = { config, lib, pkgs, ... }: {

    home.packages = with pkgs; [
      mas
      terminal-notifier
      ripgrep
      cmake
      gcc
      gnumake
      gnuplot
      jq
      alejandra
      texlab
      windsurf
      wget
      claude-code
    ];
  };
}
