{ self, inputs, ... }: {

  flake.homeModules.vvhTerminals = { config, lib, pkgs, ... }: {

    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
      ## Enable for whichever shell you plan to use!
      #enableBashIntegration = true;
      #enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        theme = "Dark+";
        background-opacity = "0.9";
        font-family = "JetBrainsMonoNL Nerd Font Mono";
        font-size = 18;
        macos-hidden = "always";
        window-width = 150;
        window-height = 50;
      };
    };

    programs.kitty = lib.mkForce {
      enable = true;
      font = {
        name = "JetBrainsMonoNL Nerd Font";
        size = 18;
      };
      settings = {
        foreground = "#ffffff";
        background = "#000000";
        background_opacity = "0.8";
        background_blur = 5;
        ### Colors start here
        # black
        color0 = "#000000";
        color8 = "#767676";
        # red
        color1 = "#c0392b";
        color9 = "#e74c3c";
        # green
        color2 = "#27ae60";
        color10 = "#2ecc71";
        # yellow
        color3 = "#f39c12";
        color11 = "#f1c40f";
        # blue
        color4 = "#2980b9";
        color12 = "#3498db";
        # magenta
        color5 = "#8e44ad";
        color13 = "#9b59b6";
        # cyan
        color6 = "#16a085";
        color14 = "#2aa198";
        #white
        color7 = "#bdc3c7";
        color15 = "#ecf0f1";
        ### colors end ###
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        window_padding_width = 10;
        symbol_map = let
          mappings = [
            "U+23FB-U+23FE"
            "U+2B58"
            "U+E200-U+E2A9"
            "U+E0A0-U+E0A3"
            "U+E0B0-U+E0BF"
            "U+E0C0-U+E0C8"
            "U+E0CC-U+E0CF"
            "U+E0D0-U+E0D2"
            "U+E0D4"
            "U+E700-U+E7C5"
            "U+F000-U+F2E0"
            "U+2665"
            "U+26A1"
            "U+F400-U+F4A8"
            "U+F67C"
            "U+E000-U+E00A"
            "U+F300-U+F313"
            "U+E5FA-U+E62B"
          ];

          in
        (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font";
      };
    };
  };
}
