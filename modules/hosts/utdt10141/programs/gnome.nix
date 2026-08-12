{ self, inputs, ... }: {

  flake.homeModules.utdt10141GnomeConfig = { config, lib, pkgs, ... }: {

    dconf.enable = true;

    home.packages = with pkgs; [
      gnome-tweaks
      dconf-editor
      gnomeExtensions.just-perfection    # same taste as nixtop's vvhGnome
      gnomeExtensions.blur-my-shell
      gnomeExtensions.appindicator
      gnomeExtensions.tiling-shell        # drag-to-tile, multi-monitor snap zones
    ];

    dconf.settings = {

      ## --- Extensions: kill Ubuntu's dock, turn on the ones we installed ---
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [ "ubuntu-dock@ubuntu.com" ];
        enabled-extensions = [
          "just-perfection-desktop@just-perfection"
          "blur-my-shell@aunetx"
          "appindicatorsupport@rgcjonas.gmail.com"
          "tilingshell@ferrarodomenico.com"
        ];
      };

      ## --- Tiling Shell: drag-to-tile zones, per-monitor aware ---
      ## Once you've tweaked layouts/gaps/keybindings via the extension's own
      ## settings UI, capture them declaratively with:
      ##   dconf dump /org/gnome/shell/extensions/tilingshell/ > tilingshell.ini
      ## and translate the keys into this block, e.g.:
      # "org/gnome/shell/extensions/tilingshell" = {
      #   inner-gaps = 8;
      #   outer-gaps = 8;
      #   snap-assist = true;
      #   enable-move-keybindings = true;
      # };

      ## --- Colors ---
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple"; # blue teal green yellow orange red pink purple slate
      };

      ## --- Wallpaper (adjust the path, or manage the file via home.file) ---
      "org/gnome/desktop/background" = {
        picture-uri = "file://${config.home.homeDirectory}/Pictures/wallpaper.jpg";
        picture-uri-dark = "file://${config.home.homeDirectory}/Pictures/wallpaper.jpg";
        picture-options = "zoom";
      };
      "org/gnome/desktop/screensaver".picture-uri =
        "file://${config.home.homeDirectory}/Pictures/wp/meep.png";

      ## --- Keyboard shortcuts: two patterns ---
      # (1) override a built-in shortcut
      "org/gnome/desktop/wm/keybindings".close = [ "<Super>q" ];

      # (2) add a fully custom one: Super+Return -> ghostty
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Open terminal";
        command = "ghostty";
        binding = "<Super>Return";
      };
    };

    ## --- Default apps ---
    xdg = {
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "google-chrome.desktop";
          "x-scheme-handler/http" = "google-chrome.desktop";
          "x-scheme-handler/https" = "google-chrome.desktop";
          "x-scheme-handler/about" = "google-chrome.desktop";
          "x-scheme-handler/unknown" = "google-chrome.desktop";
          "application/pdf" = "org.gnome.Evince.desktop";
          "inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "${config.home.homeDirectory}/docs";
        download  = "${config.home.homeDirectory}/downs";
        desktop = "${config.home.homeDirectory}/desktop";
      };
    };
  };
}
