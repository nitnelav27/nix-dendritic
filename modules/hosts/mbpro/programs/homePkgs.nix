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
      # windsurf  # 2026-11: renamed devin-desktop in nixpkgs; upstream zip 404s
      wget
      claude-code
      postgresql
    ];
  };
}
