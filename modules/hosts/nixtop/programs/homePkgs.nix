{ self, inputs, ... }: {

  flake.homeModules.nixtopHomePkgs = { config, lib, pkgs, ... }: {

    home.packages = with pkgs; [
      texlive.combined.scheme-full
      bluez
      bluez-tools
      blueman
      calibre
      cmake
      #emacs
      enchant
      electron
      feishin
      firefox
      gcc
      gnumake
      gnuplot
      grim
      grimblast
      hugo
      hypridle
      hyprpaper
      hyprpicker
      hyprpolkitagent
      hyprshot
      jq
      mako
      #mgba
      languagetool
      libreoffice-qt
      libtool
      luajitPackages.luacheck
      #nwg-displays
      #nwg-look
      openconnect
      p7zip
      pandoc
      python3
      python3Packages.pip 
      python3Packages.black 
      python3Packages.flake8 
      python3Packages.mypy
      python3Packages.debugpy
      python3Packages.isort
      pwvucontrol
      ripgrep
      scrot
      seahorse ## Graphical frontend fro GNOME Keyring
      slack
      slurp
      #spotify
      sqlite
      #supersonic-wayland
      swaybg
      texlab
      teams-for-linux 
      thunderbird
      via
      vscode
      waybar
      wl-clipboard
      wlogout
      wmenu
      wordnet
      thunar
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
