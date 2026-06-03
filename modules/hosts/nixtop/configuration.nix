{ self, inputs, ... }: {

  flake.nixosModules.nixtopConfig = { config, lib, pkgs, ... }: {

    imports = [
      inputs.agenix.nixosModules.default 
      self.nixosModules.nixtopHardware
      self.nixosModules.commonServices
      self.nixosModules.commonConfig
      self.nixosModules.nixtopServices
      self.nixosModules.nixtopMounts
      self.nixosModules.vvhGnome
    ];

    # Activate swap
    swapDevices = [{
        device = "/var/lib/swapfile";
        size = 16*1024; # Size in megabytes
    }];

    # Set your time zone.
    time.timeZone = "America/Santiago";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "es_CL.UTF-8";
        LC_IDENTIFICATION = "es_CL.UTF-8";
        LC_MEASUREMENT = "es_CL.UTF-8";
        LC_MONETARY = "es_CL.UTF-8";
        LC_NAME = "es_CL.UTF-8";
        LC_NUMERIC = "es_CL.UTF-8";
        LC_PAPER = "es_CL.UTF-8";
        LC_TELEPHONE = "es_CL.UTF-8";
        LC_TIME = "es_CL.UTF-8";
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
      };
    };

    users = {
      groups = {
        vsvh = {
          gid = 1000;
        };
      };
      users = {
        vsvh = {
          description = "Main user for desktop computer";
          isNormalUser = true;
          group = "vsvh";
          homeMode = "764";
          shell = pkgs.zsh;
          extraGroups = [
            "wheel"
            "video"
            "render"
            "networkmanager"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJCb1Zizshyqfe8h8SprkjkgDqKe+PMPDT6WvEjF+wT MacOS on mbpro m5 pro"
          ];
        };
      };
    };

    programs = {
      zsh.enable = true;
      ## Run non-nix executables
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib 
          fuse3
          icu
          nss
          openssl
          curl
          expat
          uv
        ];
      };
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        withUWSM = true;
        xwayland.enable = true;
      };
      coolercontrol.enable = true;
    };

    environment = {
      systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default. 
        wget
        rsync
        home-manager
        fastfetch 
        uv
        rpi-imager
        zstd
        lmstudio
	git
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # Required for 50-series/Wayland cursor visibility
        WLR_NO_HARDWARE_CURSORS = "1";
        # Helps SDDM and Hyprland find the correct DRM seat
        XDG_SESSION_TYPE = "wayland";
        MUTTER_DEBUG_FORCE_KMS_MODE = "simple"; # Helps GDM draw on Nvidia
      };
    };
    
    nix.settings = {
      download-buffer-size = 4096*1024;
      sandbox = true;
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    ## This is for using English and Spanish keyboard layouts
    console = {
      useXkbConfig = true; # use xkb.options in tty.
    };

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
    # to actually do that.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
