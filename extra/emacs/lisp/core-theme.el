;;; core-theme.el --- fonts, color theme, splash screen, cursor beacon -*- lexical-binding: t; -*-
;; Doom equivalent: the "Aesthetics" section of config.el (doom-font,
;; doom-theme, fancy-splash-image, beacon) plus the :ui doom module.

;; --- fonts -----------------------------------------------------------------
;; Doom exposes doom-font/doom-variable-pitch-font/doom-big-font as separate
;; knobs; plain Emacs just has faces, so we set them directly. `default' is
;; the monospace face used everywhere, `variable-pitch' is used by things
;; like org's prose rendering, and there's no dedicated "presentation" face
;; -- `vv/big-font-mode' below toggles the default face size instead.
(let ((font-size (if (eq system-type 'darwin) 20 23))
      (big-size  (if (eq system-type 'darwin) 30 35)))
  (set-face-attribute 'default nil :family "Hasklig" :height (* font-size 10))
  (set-face-attribute 'variable-pitch nil :family "Fira Sans" :height (* font-size 10))
  (defvar vv-big-font-height (* big-size 10)
    "Font height (in 1/10pt) used by `vv/big-font-mode', e.g. for presentations.")
  (defvar vv-normal-font-height (* font-size 10)))

(define-minor-mode vv/big-font-mode
  "Toggle a larger default font, e.g. before screen-sharing or presenting."
  :global t
  (set-face-attribute 'default nil :height (if vv/big-font-mode
                                                vv-big-font-height
                                              vv-normal-font-height)))

;; --- color theme -------------------------------------------------------
;; doom-themes is a standalone package (not part of the Doom framework) that
;; ships all the doom-* themes, so `doom-theme' from config.el maps directly.
(use-package doom-themes
  :init
  ;; bold/italic used to be set via `after! doom-themes'; here the package
  ;; IS what triggers this file's :init, so it's equivalent.
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :config
  (load-theme 'doom-Iosvkem t)
  ;; doom-themes' own tweak for org-mode fontification, matching what the
  ;; doom `org' module enables automatically. `doom-themes-org-config' lives
  ;; in a separate file (doom-themes-ext-org.el) that isn't autoloaded just
  ;; by requiring `doom-themes' itself, so it needs an explicit `require'.
  (require 'doom-themes-ext-org)
  (doom-themes-org-config))

;; Doom's "load a new theme" binding used counsel-load-theme (Ivy). We use
;; plain `load-theme' with completion (vertico, from core-completion.el,
;; already improves `completing-read' for this) instead of pulling in Ivy.
(defun vv/load-theme ()
  "Prompt for and load a theme, disabling any currently active ones first."
  (interactive)
  (let ((theme (intern (completing-read "Load theme: "
                                         (mapcar #'symbol-name (custom-available-themes))))))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)))

;; --- comment/keyword slant, straight from custom.el's face tweaks --------
(custom-set-faces
 '(font-lock-comment-face ((t (:slant italic))))
 '(font-lock-keyword-face ((t (:slant italic :weight bold)))))

;; --- misc aesthetics ---------------------------------------------------
(delete-selection-mode 1)   ; typing over a selection replaces it, like every other editor

;; --- splash screen -------------------------------------------------------
;; Doom's doom-dashboard module + `fancy-splash-image'. `dashboard' is the
;; standalone package most "Emacs from scratch" guides reach for; it's not
;; pixel-identical to Doom's dashboard but covers the same job (a startup
;; screen with an image and quick links) without depending on Doom.
(use-package dashboard
  :init
  (setq dashboard-startup-banner (expand-file-name "smithers.png" vv-emacs-dir)
        dashboard-center-content t
        dashboard-items '((recents  . 5)
                           (projects . 5)
                           (agenda   . 5)))
  :config
  (dashboard-setup-startup-hook))

;; --- cursor beacon -------------------------------------------------------
;; Ported verbatim from config.el's `use-package! beacon' block.
(use-package beacon
  :custom
  (beacon-push-mark 10)
  (beacon-color "#cc342b")
  (beacon-blink-delay 0.3)
  (beacon-blink-duration 0.3)
  :config
  (beacon-mode 1)
  (global-hl-line-mode 1))

(provide 'core-theme)
