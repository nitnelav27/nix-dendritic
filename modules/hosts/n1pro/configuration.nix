{ self, inputs, ... }: {

  flake.nixosModules.n1proConfig = { config, lib, pkgs, ... }: {

    imports = [
      inputs.agenix.nixosModules.default
      self.nixosModules.n1proHardware
      self.nixosModules.commonServices 
      self.nixosModules.commonConfig
      self.nixosModules.n1proServices
    ];

    time.timeZone = "America/Argentina/Buenos_Aires";

    i18n.defaultLocale = "en_US.UTF-8";

    users = {
      groups = {
        vvh = {
          gid = 1000;
        };
      };
      users = {
        vvh = {
          description = "Valentín en Aoostar N1 Pro, Buenos Aires";
          isNormalUser = true;
          uid = 1000;
          group = "vvh";
          homeMode = "764";
          shell = pkgs.zsh;
          extraGroups = [
            "wheel"
            "video"
            "render"
            "networkmanager"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9CaJu6FJJ4s4NaL546RufQdrw7UB4zlChTN10avrpt valentinvergara@gmail.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
          ];
        };
      };
    };

    ###################
    ### WM + SESSION ###
    ###################
    ## The actual Sway config (keybinds, bar, idle/lock) lives in the
    ## home-manager module modules/programs/sway.nix (flake.homeModules.vvhSway).
    ## This just installs the system-wide sway + registers it as a session.
    programs = {
      zsh.enable = true;
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      ## Run non-nix executables, same as nixtop, in case you want to drop in
      ## a non-packaged binary later.
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          openssl
          curl
        ];
      };
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;
      pam.services.greetd.enableGnomeKeyring = true;
    };

    ## Minimal, TUI login manager instead of nixtop's SDDM+GNOME hybrid --
    ## no Qt/QML greeter theme, no gnome-shell session dependency, it just
    ## authenticates and execs sway directly. Fits the "as little resource
    ## use as possible" goal better on the N150 than a full display manager.
    ##
    ## If you'd rather match nixtop's SDDM+GNOME session-picker look across
    ## machines, swap this block for `self.nixosModules.vvhGnome` in the
    ## imports above and drop `services.greetd` here.
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command =
        "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd sway";
    };

    services.gnome.gnome-keyring.enable = true; # just the keyring daemon, not the shell

    xdg.portal = {
      enable = true;
      wlr.enable = true; # screen share / screenshot portal for sway
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # file picker etc.
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI for Alder-Lake-N/Twin Lake (Gen12/Xe-LP) -- real CPU savings on video playback
        libvdpau-va-gl
      ];
    };

    environment = {
      systemPackages = with pkgs; [
        vim
        wget
        rsync
        home-manager
        fastfetch
        btop
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        LIBVA_DRIVER_NAME = "iHD";
      };
    };

    ## This is for using English and Spanish keyboard layouts on the console too
    console.useXkbConfig = true;

    home-manager.users.vvh = self.homeModules.vvhN1pro;

    # First NixOS release this host was actually installed with -- do not
    # change after install, see the comment on other hosts' configuration.nix.
    system.stateVersion = "26.05";
  };
}
