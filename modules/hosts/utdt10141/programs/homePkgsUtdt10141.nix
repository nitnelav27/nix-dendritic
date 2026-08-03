{ self, inputs, ... }: {

  flake.homeModules.utdt10141HomePkgs = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      sl
      texlive.combined.scheme-full
      cmake
      #emacs
      enchant
      electron
      firefox
      gcc
      gnumake
      gnuplot
      grim
      grimblast
      hugo
      jq
      mako
      #mgba
      languagetool
      libreoffice-qt
      libtool
      luajitPackages.luacheck
      #nwg-displays
      #nwg-look
      p7zip
      pandoc
      python3
      python3Packages.pip 
      python3Packages.black 
      python3Packages.flake8 
      python3Packages.mypy
      python3Packages.debugpy
      python3Packages.isort
      ripgrep
      scrot
      slack
      slurp
      #spotify
      sqlite
      #supersonic-wayland
      texlab
      teams-for-linux 
      thunderbird
      via
      vscode
      wordnet
      zathura
      zoom-us
      #google-chrome
      claude-code
      # (rstudioWrapper.override{
      #   packages = with rPackages; [
      #     ggplot2
      #     dplyr
      #     tidyr
      #     readr
      #     pacman
      #     quarto
      #     arrow ## parquet support
      #     tidyverse
      #     psych
      #     sjmisc
      #     sjPlot
      #     openxlsx
      #   ];
      # })
      # quarto
    ];
  };
}
