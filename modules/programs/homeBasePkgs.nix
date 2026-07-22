{ self, inputs, ... }: {

  flake.homeModules.vvhHomeBasePkgs = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      stdenv
      btop
      fastfetch
      eza
      tldr
      duf
      aspell
      aspellDicts.en
      aspellDicts.es
      bat 
      dialog
      dig
      fd
      fzf
      hunspell
      hunspellDicts.en_US
      hunspellDicts.es_CL
      iperf
      killall
      pyright
      nixpkgs-fmt
      nil
      shellcheck
      tree
      unzip
      zip
      ## Testing python environments
      direnv
      nix-direnv
      ### Fonts start here
      barlow
      fira
      hasklig
      source-code-pro
      material-design-icons
      material-icons
      noto-fonts
      roboto
      ubuntu-sans
      ubuntu-sans-mono
      weather-icons
      font-awesome
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.symbols-only
      ### End of fonts
    ]
    # Logic: Only add nixfmt if we are NOT on Darwin
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        nixfmt
        cliphist
    ];

    fonts = {
      fontconfig.enable = true;
    };
  };
}
