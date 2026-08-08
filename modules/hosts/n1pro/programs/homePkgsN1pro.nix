{ self, inputs, ... }: {

  flake.homeModules.n1proHomePkgs = { config, lib, pkgs, ... }: {

    ## Kept small on purpose since this is a fresh host -- add what you
    ## actually end up wanting here as you go, same as nixtopHomePkgs /
    ## mediaCCPHomePkgs do for their machines.
    home.packages = with pkgs; [
      firefox
      thunar
      p7zip
      unzip
      wmenu # fallback dmenu-style launcher if you ever want something even lighter than rofi
    ];
  };
}
