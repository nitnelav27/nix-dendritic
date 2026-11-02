{ self, inputs, ... }: {

  flake.nixosModules.n1proServices = { config, lib, pkgs, ... }: {

    networking = {
      hostName = "n1pro";
      ## Static IP on the wired NIC, still managed by NetworkManager (FortiClient
      ## and Wi-Fi keep working). 10.27.81.138 must match the NFS allowlist on
      ## nas-ar/rpi-ar (modules/hosts/{nas-ar,rpi-ar}/services/nfs.nix) and
      ## mbpro's ssh alias for n1pro.
      networkmanager = {
        enable = true;
        ensureProfiles.profiles."enp4s0-static" = {
          connection = {
            id = "enp4s0-static";
            type = "ethernet";
            interface-name = "enp4s0";
            autoconnect = true;
            autoconnect-priority = 100; # win over NM's auto "Wired connection 1" (DHCP)
          };
          ipv4 = {
            method = "manual";
            address1 = "10.27.81.138/24,10.27.81.1";
            dns = "10.27.81.1;";
            ignore-auto-dns = true;
          };
          ipv6.method = "auto";
        };
      };
    };

    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        ports = [ 1186 ]; # matches the port your other hosts already use
        settings.PasswordAuthentication = true;
      };

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true; # provides `wpctl`, used by the sway media keybinds
      };

      udisks2.enable = true;
      avahi.enable = true;
      printing.enable = false;

      forticlient = {
        enable = true;
        package = inputs.forticlient-nixos.packages.x86_64-linux.forticlient.override {
          version = "7.4.8.1904";   # match what EMS expects; module pins 7.4.7.1868
          sha256 = "sha256-j5OcQunefHIyUSdyMNqRO584+TrSolNaPr134Tm/7YE=";             # nix-prefetch-url <deb from repo.fortinet.com>
        };
      };
    };

    ## Uncomment if this particular N1 Pro unit has a Wi-Fi/Bluetooth module --
    ## some Aoostar N1 Pro variants do, some rely on wired-only + optional
    ## USB/M.2 Wi-Fi cards, so left off by default.
    # hardware.bluetooth.enable = true;
    # services.blueman.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    ## forticlient-nixos still lists `xorg.libX11` & co. for nix-ld, and every
    ## one of those trips nixpkgs' "xorg package set has been deprecated"
    ## warning. Point the old names at the new top-level packages so the
    ## warnings never fire. Drop this once upstream switches to the new names.
    nixpkgs.overlays = [
      (final: prev: {
        xorg = prev.xorg // {
          libX11 = final.libx11;
          libxcb = final.libxcb;
          libXcomposite = final.libxcomposite;
          libXcursor = final.libxcursor;
          libXdamage = final.libxdamage;
          libXext = final.libxext;
          libXfixes = final.libxfixes;
          libXi = final.libxi;
          libXrandr = final.libxrandr;
          libXrender = final.libxrender;
          libXScrnSaver = final.libxscrnsaver;
          libXtst = final.libxtst;
          libxshmfence = final.libxshmfence;
        };
      })
    ];
  };
}
