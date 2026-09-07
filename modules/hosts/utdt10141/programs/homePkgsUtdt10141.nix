{ self, inputs, ... }: {

  flake.homeModules.utdt10141HomePkgs = { config, lib, pkgs, ... }: {
    ## Desktop/end-user applications and general CLI utilities used to live
    ## here too (texlive, papers, sioyek, firefox, libreoffice-qt,
    ## thunderbird, spotify, zathura, teams-for-linux, pandoc, gnuplot, hugo,
    ## languagetool, wordnet, p7zip, qpdf, enchant, electron, gcc/gnumake/
    ## cmake/libtool, jq, sqlite, uv) -- those now come from apt instead, see
    ## apt/packages.txt and apt/README.md for the per-package apt/snap/deb
    ## caveats (firefox & thunderbird are Ubuntu snaps by default, spotify &
    ## teams-for-linux need their own apt repos, sioyek/papers/languagetool/
    ## uv don't have a clean apt path at all -- READ apt/README.md before
    ## assuming this list is a 1:1 swap).
    ##
    ## What's left here is: hardware/wayland-tool stuff specific to this
    ## machine's peripherals (projecteur, via) and screenshot tools, which
    ## stayed in Nix mainly because nobody's checked yet whether they're in
    ## Ubuntu's apt archive (worth revisiting); and texlab/ltex-ls-plus,
    ## which stay because nvf.nix and vscode.nix reference them directly as
    ## LSP servers (config-coupled, not standalone apps).
    home.packages = with pkgs; [
      sl
      (config.lib.nixGL.wrap projecteur)
      grim
      grimblast
      mako
      scrot
      slurp
      via
      claude-code
      texlab
      ltex-ls-plus ## LSP language server for latex, referenced by vscode.nix
      # (rstudioWrapper.override{
      #   packages = with rPackages; [
      #     ggplot2
      #     dplyr
      #     tidyr
      #     readr
      #     pacman
      #     quarto
      #     arrow ## parquet support
      #     tidyverse
      #     psych
      #     sjmisc
      #     sjPlot
      #     openxlsx
      #   ];
      # })
      # quarto
      teams-for-linux 
      languagetool
      enchant 
      uv 
      tldr
      fd
      ### Fonts start here
      barlow
      fira
      hasklig
      source-code-pro
      material-design-icons
      material-icons
      noto-fonts
      roboto
      ubuntu-sans
      ubuntu-sans-mono
      weather-icons
      font-awesome
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.symbols-only
      ### End of fonts
    ];

    ## sioyek used to be the default PDF handler; it's gone from Nix now
    ## (see comment above), so this falls through to gnome.nix's
    ## "application/pdf" = "org.gnome.Evince.desktop", which was actually
    ## a silent conflict with this line before -- whichever module home-manager
    ## merged last was winning. Pick a different apt-installed reader here
    ## if you don't want Evince.

    ## VS Code itself now comes only from programs.vscode.enable (vvhVSCode) —
    ## it used to also be listed directly in home.packages above, which just
    ## duplicated the binary and made it ambiguous which `code` was on PATH.
    ##
    ## Python moved from one global pinned pythonEnv (numpy/pandas/jupyter/...)
    ## to uv: per-project pyproject.toml + `uv venv`/`uv add` for library
    ## dependencies -- each project gets its own venv, reproducible via its
    ## own uv.lock, and VS Code's Python extension auto-detects each
    ## project's .venv (no more hardcoded python.defaultInterpreterPath /
    ## jupyter.jupyterServerType here).
    ##
    ## Standalone dev-tool CLIs that should exist regardless of which project
    ## you're in still get a declared list here, but the actual install goes
    ## through `uv tool install` -- uv's own imperative/mutable state under
    ## ~/.local/share/uv -- refreshed idempotently on every `home-manager
    ## switch`, same pattern as the VS Code settings-merge activation script
    ## in vscode.nix. debugpy is deliberately left out: VS Code's Python
    ## extension bundles its own debugger, so a project only needs debugpy
    ## itself if it wants to run it standalone outside VS Code.
    home.activation.uvGlobalTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for tool in black flake8 mypy isort; do
        ${pkgs.uv}/bin/uv tool install --quiet "$tool" || true
      done
    '';
  };
}
