;;; core-emacs-files.el --- dired, ibuffer, undo, vc -*- lexical-binding: t; -*-
;; Doom equivalent: the :emacs module (dired +dirvish +icons, electric,
;; ibuffer +icons, undo, vc). Named "core-emacs-files" rather than
;; "core-emacs" only to avoid colliding with the built-in `emacs' feature
;; name.

;; --- dired -----------------------------------------------------------------
;; +dirvish: Doom's dired module can swap in dirvish, a more modern
;; file-manager-style overlay on dired. We enable it directly rather than
;; going through vanilla dired first.
;; Nix-installed packages have no package.el autoloads, so mode-enabling
;; calls need to be in `:config' (after use-package's own `require'), not
;; `:init' (runs before load, hits void-function) -- same fix as elsewhere
;; in this config.
(use-package dirvish
  :custom
  (dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))
  :config
  (dirvish-override-dired-mode)
  (dirvish-peek-mode 1)) ; preview file at point in a side window

;; +icons: file-type icons in dired/dirvish, via nerd-icons (no need for
;; the older all-the-icons + a separate Nerd Font patch step).
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; --- electric-indent -----------------------------------------------------
;; Built into Emacs; Doom's `electric' module just tunes it slightly to be
;; less surprising for keyword-based languages (python, etc). The default
;; is fine for most modes; lang-prog.el sets per-mode electric-indent-chars
;; where it matters.
(electric-indent-mode 1)
(electric-pair-mode -1) ; smartparens (core-editor.el) already handles pairs

;; --- ibuffer ---------------------------------------------------------------
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; --- undo ------------------------------------------------------------------
;; Doom's `undo' module uses undo-fu + undo-fu-session for persistent,
;; linear (non-tree) undo/redo -- exactly what evil-mode expects, and what
;; `evil-undo-system' in core-evil.el points at.
(use-package undo-fu)

(use-package undo-fu-session
  :config (global-undo-fu-session-mode 1))

;; --- vc: version control + diff-hl already covers the fringe gutter -------
;; (diff-hl itself lives in core-ui.el next to the rest of the "gutter"
;; UI elements; this section is just the plain vc.el tuning Doom's `vc'
;; module does.)
(setq vc-follow-symlinks t
      vc-handled-backends '(Git))

(provide 'core-emacs-files)
