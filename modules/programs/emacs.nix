{ self, inputs, ... }: {

  ## Emacs, built "from scratch" (no Doom framework) the same way nvf.nix
  ## builds Neovim declaratively: every package the config in extra/emacs
  ## expects is pinned here and baked into the `emacs` binary itself via
  ## `emacsWithPackages`, instead of being fetched at runtime by
  ## package.el/straight.el/elpaca. Adding a package means adding a line
  ## here and running `home-manager switch`, not editing packages.el and
  ## running `doom sync`.
  ##
  ## NOTE: a handful of the emacsPackages attribute names below are best
  ## guesses at the nixpkgs-generated MELPA/ELPA name for their upstream
  ## package (nixpkgs' generator mostly mirrors the MELPA recipe name, but
  ## not always). Run `home-manager switch` and fix any that don't
  ## evaluate -- `nix search nixpkgs emacsPackages.<guess>` finds the
  ## right name fast.
  flake.homeModules.vvhEmacs = { config, pkgs, lib, ... }:
    let
      emacsPkg = pkgs.emacs30-pgtk; # pgtk = native Wayland support, matches hyprland.nix/niri.nix
      emacsWithPackages = (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (epkgs: with epkgs; [
        ## :completion
        vertico vertico-posframe orderless marginalia consult embark embark-consult
        nerd-icons-completion nerd-icons
        company company-box

        ## :ui
        doom-themes doom-modeline dashboard hl-todo ligature minimap diff-hl
        popper unicode-fonts perspective

        ## :editor
        evil evil-collection evil-surround evil-commentary evil-matchit evil-multiedit evil-goggles
        general which-key
        yasnippet yasnippet-snippets auto-yasnippet adaptive-wrap smartparens

        ## :emacs
        dirvish nerd-icons-dired nerd-icons-ibuffer undo-fu undo-fu-session

        ## :term
        vterm

        ## :checkers
        flycheck flycheck-posframe flyspell-correct langtool

        ## :tools
        eros quickrun define-word lsp-mode lsp-ui magit pdf-tools rainbow-mode

        ## :lang -- programming
        nix-mode lsp-pyright cython-mode json-mode toml-mode yaml-mode lua-mode
        markdown-mode ess swift-mode

        ## :lang -- latex
        auctex cdlatex

        ## :lang -- org, citations, export backends
        org org-superstar gnuplot ox-hugo ox-pandoc org-tree-slide
        org-ref org-roam org-roam-bibtex
      ]);
    in
    {
      home.packages = [
        emacsWithPackages
      ] ++ (with pkgs; [
        ## LSP servers lsp-mode shells out to that aren't already installed
        ## elsewhere in this repo. nil (nix) and pyright (python) come from
        ## utdt10141NixTools already -- see nixTools.nix -- and texlab
        ## (latex) from utdt10141HomePkgs -- see homePkgsUtdt10141.nix.
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        clang-tools # clangd, for :lang cc

        ## mu/mbsync back email.el's mu4e block. mu4e itself ships as elisp
        ## inside `mu`'s output (not a separate emacsPackages entry), so its
        ## share/emacs/site-lisp/mu4e directory is added to EMACSLOADPATH
        ## below rather than listed in emacsWithPackages above.
        mu
        isync # provides `mbsync`, which mu4e-get-mail-command shells out to

        ## +enchant spellchecking backend for flyspell (core-checkers.el).
        enchant

        ## vterm needs libvterm at runtime; the emacsPackages.vterm
        ## derivation already declares this as a build input for its
        ## dynamic module, so nothing else is required here.
      ]);

      ## Puts mu4e.el (bundled inside `mu`, not a separate Nix package) on
      ## Emacs' load-path, and points EDITOR-adjacent tooling at emacsclient
      ## instead of nvim when you explicitly want Emacs for something.
      home.sessionVariables = {
        EMACSLOADPATH = "${pkgs.mu}/share/emacs/site-lisp/mu4e:";
      };

      ## The config itself: early-init.el/init.el/lisp/*.el, plus the
      ## agenda files, snippets, and splash image that used to live under
      ## $DOOMDIR (~/.config/doom). Emacs 27+ checks $XDG_CONFIG_HOME/emacs
      ## (~/.config/emacs) when ~/.emacs.d doesn't exist, so this is a
      ## drop-in replacement for the old ~/.config/doom home.file entry in
      ## hosts/utdt10141/home.nix -- same pattern as the matplotlib/
      ## figlet-fonts entries there.
      home.file.emacs-config = {
        enable = true;
        executable = false;
        recursive = true;
        source = self + "/extra/emacs";
        target = ".config/emacs";
      };
    };
}
