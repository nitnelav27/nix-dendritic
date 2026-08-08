{ self, inputs, ... }: {

  flake.nixosModules.n1proServices = { config, lib, pkgs, ... }: {

    networking = {
      hostName = "n1pro";
      networkmanager.enable = true;
      # Static DNS/timeserver overrides like nixtop's aren't needed here yet --
      # add them if n1pro moves to a fixed LAN IP.
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
    };

    ## Uncomment if this particular N1 Pro unit has a Wi-Fi/Bluetooth module --
    ## some Aoostar N1 Pro variants do, some rely on wired-only + optional
    ## USB/M.2 Wi-Fi cards, so left off by default.
    # hardware.bluetooth.enable = true;
    # services.blueman.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
