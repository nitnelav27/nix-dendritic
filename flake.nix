{
  ## nixos-raspberrypi ships a binary cache for its downstream RPi5 kernel and
  ## bootloader tooling, built against its OWN pinned nixpkgs (see the
  ## comment on the `nixos-raspberrypi` input below for why we deliberately
  ## do NOT follow the shared nixpkgs for it).
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-anylinuxfs = {
      url = "github:nohajc/homebrew-anylinuxfs";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-claude-code.url = "github:ryoppippi/nix-claude-code";

    ## Raspberry Pi 5 board profile (kernel pin, device trees, extlinux, initrd
    ## modules for NVMe / PCIe / RP1). Deliberately NOT following nixpkgs:
    ## nixos-hardware has no nixpkgs input to follow.
    ## Only used by rpi-ccp; rpi-ar uses nixos-raspberrypi instead (see below).
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ## RPi5 boot for rpi-ar: this project ships its own downstream kernel,
    ## device-tree overlays and a native "kernel" bootloader mode where the
    ## Pi 5 firmware loads the kernel directly per NixOS generation -- no
    ## U-Boot, no extlinux.conf, none of the chainloading rpi-ar's old setup
    ## depended on. It has its own binary cache (nixConfig above), built
    ## against ITS pinned nixpkgs -- deliberately NOT following the shared
    ## `nixpkgs` input here, so rpi-ar gets full cache hits (incl. the
    ## downstream kernel) instead of slow from-source rebuilds.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
