{ self, inputs, ... }: {

  flake.nixosModules.nixtopServices = { config, lib, pkgs, ... }: {

    security = {
      rtkit.enable = true;
      pam = {
        services = {
          gdm.enableGnomeKeyring = true;
        };
      };
    };
    
    imports = [ inputs.solaar.nixosModules.default ];

    hardware = {
      bluetooth.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
        # extraPackages = with pkgs; [
        #   intel-media-driver
        #   libva-vdpau-driver
        #   libvdpau-va-gl
        # ];
      };
      nvidia = {
        # Modesetting is required for Hyprland
        modesetting.enable = true;
        # Nvidia power management. Experimental, and can cause sleep/suspend issues.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;
        # Use the NVidia open source kernel module (not to be confused with nouveau)
        # This is generally recommended for newer cards (Turing and newer)
        open = true;
        # Enable the Nvidia settings menu,
	      # accessible via `nvidia-settings`.
        nvidiaSettings = true;
        # Select the appropriate driver version for your GPU.
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = [
        "kvm-amd"
      ];
      initrd = {
        availableKernelModules = [ 
          "nvme" 
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod" 
        ];
        kernelModules = [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
          "it87"
        ];
      };
      ## uncomment below to build a sd-image for raspberry pi
      # binfmt.emulatedSystems = [ "aarch64-linux" ];
      supportedFilesystems = [ "nfs" ];
      kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
        # This tells the kernel to ignore the simple boot splash and wait for the real driver
        "video=efifb:off"
        "acpi_enforce_resources=lax"
      ];
      extraModulePackages = [
        config.boot.kernelPackages.it87
      ];
      extraModprobeConfig = ''
        options it87 force_id=0x8696 ignore_resource_conflict=1
      '';  
    };

    services = { 
      openssh = {
        enable = true;
        openFirewall = true;
        ports = [ 1186 ];
        settings = {
          PasswordAuthentication = true;
        };
        extraConfig = ''
          AllowTcpForwarding yes
        '';
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [{
              name = "libpipewire-module-raop-discover";
            }];
          };
        };
        wireplumber.extraConfig = {
          "10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [
                "hsp_hs"
                "hsp_ag"
                "hfp_hf"
                "hfp_ag"
              ];
            };
          };
        };
      };
      solaar = {
        enable = true;
        batteryIcons = "solaar";
      };
      hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
      };
      gnome = {
        gnome-keyring.enable = true;
      };
      greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
          user = "greeter";
        };
      };
      # ollama = {
      #   enable = true;
      #   package = pkgs.ollama-cuda;
      #   loadModels = [
      #     "llama3.1:8b"
      #     "deepseek-r1:8b"
      #     "deepseek-r1:14b"
      #     "gemma3:12b"
      #     "qwen3:14b"
      #     "llava:13b"
      #     "llama3.2-vision:11b"
      #   ];
      # };
      # open-webui.enable = true;
      xserver = {
        videoDrivers = [
          "nvidia"
        ];
      #   enable = true;
      #   xkb = {
      #     layout = "us,es";
      #     variant = "";
      #     options = "grp:caps_toggle";
      #   };
      };
      avahi.enable = true;
      udisks2.enable = true;
      blueman.enable = true;
      hypridle.enable = true;
      timesyncd.enable = false;
      chrony.enable = true;
      printing.enable = true;
    };

    networking = {
      hostName = "nixtop";
      networkmanager = {
        enable = true;
        dns = "none";
      };
      useDHCP = false;
      dhcpcd.enable = false;
      nameservers = [
        "10.27.115.1"
      ];
      timeServers = lib.mkForce [
        "0.south-america.pool.ntp.org"
        "1.south-america.pool.ntp.org"
        "time.google.com"
      ];
    };

    systemd = {
      services = {
        display-manager = {
          after = [
            "graphical-desktop.target"
            "network-online.target" 
          ];
        };
      };
      user = {
        extraConfig = ''
          DefaultEnvironment="PATH=/usr/bin:/bin"
          DefaultEnvironment="LIBVA_DRIVER_NAME=nvidia"
          DefaultEnvironment="GBM_BACKEND=nvidia-drm"
          DefaultEnvironment="__GLX_VENDOR_LIBRARY_NAME=nvidia"
        '';
      };
    };

  };

}
