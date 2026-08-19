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
        #"whatsapp"
        "via"
        "lm-studio"
        "ghostty"
        "rar"
        "skim"
        "raspberry-pi-imager"
      ];
      brews = [
        "imagemagick"
        "mas"
        "nohajc/anylinuxfs/anylinuxfs"
        "e2fsprogs"
      ];
      onActivation = {
        cleanup = "zap";
        upgrade = true;
      };
    };
  };
}
