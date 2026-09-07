{ self, inputs, ... }: {

  ## utdt10141 gets its CLI/desktop *applications* from apt (see ../../../../apt/),
  ## not Nix -- see apt/README.md for the reasoning. This module replaces
  ## vvhHomeBasePkgs (which every other host still uses) with only the
  ## handful of tools that stay Nix-managed here because they're wired
  ## directly into a declarative config elsewhere in this repo rather than
  ## being standalone apps:
  ##   - nil, pyright     -> LSP servers nvf.nix points at directly
  ##   - ripgrep, fzf      -> back fzf-lua inside nvf.nix
  ##   - nixpkgs-fmt, nil  -> used to edit *this* flake itself
  ##   - shellcheck        -> nvf.nix bash linting
  ## Everything homeBasePkgs used to provide beyond this (btop, fastfetch,
  ## eza, tldr, duf, aspell/hunspell + dicts, bat, dialog, dig, iperf,
  ## killall, tree, unzip, zip, cliphist, and all the fonts) moved to
  ## apt/packages.txt instead -- see apt/README.md for the apt/snap/deb
  ## package name for each, including the ones that need a caveat (nerd
  ## fonts especially).
  flake.homeModules.utdt10141NixTools = { pkgs, ... }: {
    home.packages = with pkgs; [
      nil
      pyright
      ripgrep
      fzf
      nixpkgs-fmt
      shellcheck
    ];
  };
}
