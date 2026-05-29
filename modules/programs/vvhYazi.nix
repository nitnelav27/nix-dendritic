{ self, inputs, ... }: {

  flake.homeModules.vvhYazi = { config, lib, pkgs, ... }: {

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };
      shellWrapperName = "y";
      settings = {
        mgr = {
          ratio = [ 1 4 3 ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
        };
        preview = {
          wrap = "yes";
          image_filter = "lanczos3";
          image_quality = 90;
          tab_size = 1;
          max_width = 600;
          max_height = 900;
          cache_dir = "";
          ueberzug_scale = 1;
          ueberzug_offset = [ 0 0 0 0 ];
        };
        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };

        opener = {
          edit = [
            { run = ''nvim "$@"''; block = true; desc = "Neovim"; }
          ];
          play = [
            { run = ''mpv "$@"''; orphan = true; desc = "MPV"; }
          ];
          pdf_reader = [
            { run = ''zathura "$@"''; desc = "Zathura"; block = true; }
          ];
        };

        open = {
          prepend_rules = [
            # Use Neovim for all plain text
            { mime = "text/*"; use = "edit"; }
            # Explicitly catch .nix files
            { url = "*.nix"; use = "edit"; }
            # Common media openers
            { mime = "video/*"; use = "play"; }
            { mime = "audio/*"; use = "play"; }
          ];
          rules = [
            { mime = "application/pdf"; use = "pdf_reader"; }
          ];
        };
      };
    };
  };
}
