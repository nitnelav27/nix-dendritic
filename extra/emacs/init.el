;;; init.el --- entry point -*- lexical-binding: t; -*-

;; This replaces Doom's `init.el' + `config.el' + `packages.el' trio.
;; There is no Doom framework underneath: every package below is provided
;; by Nix (see modules/programs/emacs.nix, which builds `emacsWithPackages'
;; and symlinks it in) and every bit of configuration lives in plain
;; `use-package' forms in ./lisp/*.el.
;;
;; Because packages are already on `load-path' via Nix, every `use-package'
;; block below deliberately omits `:ensure' (or sets it to nil): there is
;; nothing for use-package to install, it only wires up autoloads, hooks,
;; and settings. This is the "Nix-declarative" package strategy: add a
;; package -> add it to emacs.nix's package list -> `home-manager switch'.
;;
;; The module layout mirrors Doom's own category prefixes (:ui, :editor,
;; :completion, :emacs, :term, :checkers, :tools, :lang, :email) so it's
;; easy to map "where did doom-module X go?" to "which lisp/*.el file".

;; --- use-package itself ------------------------------------------------
;; use-package has been built into Emacs since 29, no package to install.
(require 'use-package)
(setq use-package-always-defer nil   ; load eagerly unless a block says :defer
      use-package-expand-minimally t ; smaller, faster-to-read expansion
      use-package-compute-statistics t) ; lets `use-package-report' show load times

;; --- where our own lisp/ modules live -----------------------------------
(defvar vv-emacs-dir (file-name-directory (or load-file-name buffer-file-name))
  "Directory this init.el lives in, i.e. ~/.config/emacs.")
(add-to-list 'load-path (expand-file-name "lisp" vv-emacs-dir))

;; --- module load order ---------------------------------------------------
;; Order matters a little: theme/UI first so there's no flash of unstyled
;; Emacs, evil before anything that binds evil keymaps, completion before
;; the things that plug into it (org, lsp, etc).
(require 'core-theme)        ; fonts, doom-theme equivalent, splash image, beacon
(require 'core-ui)           ; modeline, dashboard, hl-todo, ligatures, minimap, popups, workspaces
(require 'core-completion)   ; vertico/orderless/consult/embark + company
(require 'core-evil)         ; evil-mode + leader key (general.el) + which-key
(require 'core-editor)       ; snippets, folding, word-wrap, smartparens, file templates
(require 'core-emacs-files)  ; dired+dirvish, ibuffer, undo, vc/diff-hl, electric-indent
(require 'core-term)         ; eshell, shell, term, vterm
(require 'core-checkers)     ; flycheck, flyspell(+enchant), grammar (langtool)
(require 'core-tools)        ; eval overlays, dictionary lookup, lsp-mode, magit, pdf-tools, rainbow-mode
(require 'lang-prog)         ; emacs-lisp, nix, python, sh, cc, yaml, json, lua, markdown, ess, swift, data
(require 'lang-latex)        ; AUCTeX + CDLaTeX
(require 'lang-org)          ; org-mode, org-ref, org-roam, LaTeX export settings
(require 'email)             ; mu4e (+gmail context)
(require 'keybindings)       ; the SPC leader-key bindings that don't belong to one module

;; --- startup GC hand-back -------------------------------------------------
;; Undo the early-init.el GC/file-name-handler relaxation now that startup
;; (package loading) is finished, so normal editing gets normal GC pauses
;; instead of one enormous pause the first time a threshold is crossed.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024) ; 64MB, generous but not silly
                  gc-cons-percentage 0.1
                  file-name-handler-alist vv--file-name-handler-alist)
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds" (float-time (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; custom.el is where `M-x customize' writes generated `custom-set-variables'
;; / `custom-set-faces' forms. Keeping it a separate file (not appended to
;; this one) means `customize' can rewrite it freely without ever touching
;; hand-written config -- same reasoning Doom had for keeping it apart from
;; config.el.
(setq custom-file (expand-file-name "custom.el" vv-emacs-dir))
(when (file-exists-p custom-file)
  (load custom-file))
