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
        "adobe-acrobat-reader"
        "mactex"
        "whatsapp"
        "via"
        "lm-studio"
        "ghostty"
        "rar"
        "skim"
      ];
      brews = [
        "imagemagick"
        "mas"
      ];
      onActivation = {
        cleanup = "zap";
        upgrade = true;
      };
    };
  };
}
