{ self, inputs, ... }: {

  flake.darwinModules.mbproHomebrew = { config, lib, pkgs, ... }: {

    homebrew = {
      enable = true;
      casks = [
        "firefox"
        "kitty"
        "slack"
        "calibre"
        "zoom"
        #"adobe-acrobat-reader"
        "mactex"
        "whatsapp"
        "via"
        "lm-studio"
        "ghostty"
        "rar"
        "skim"
        "raspberry-pi-imager"
        "google-chrome"
      ];
      brews = [
        "imagemagick"
        "mas"
        "nohajc/anylinuxfs/anylinuxfs"
        "e2fsprogs"
        "postgresql"
        "node"
      ];
      onActivation = {
        cleanup = "zap";
        upgrade = true;
      };
    };
  };
}
