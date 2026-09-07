;;; core-ui.el --- modeline, ligatures, minimap, popups, workspaces -*- lexical-binding: t; -*-
;; Doom equivalent: the rest of the :ui module block in init.el (doom,
;; doom-quit, emoji, fill-column, hl-todo, ligatures, minimap, modeline,
;; ophints, popup, unicode, vc-gutter, vi-tilde-fringe, workspaces).

;; --- modeline --------------------------------------------------------------
;; doom-modeline is, like doom-themes, a standalone package -- it's what
;; Doom's `modeline' module wraps, so this is a direct port.
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-file-name-style 'truncate-with-project))

;; --- quit confirmation -----------------------------------------------------
;; Doom's `doom-quit' module just asks "are you sure?" with a random quip.
;; We keep the "are you sure" part, skip the quips (Doom-specific flavor).
(setq confirm-kill-emacs #'y-or-n-p)

;; --- fill-column indicator -------------------------------------------------
(use-package display-fill-column-indicator
  :ensure nil ; built into Emacs
  :hook (prog-mode . display-fill-column-indicator-mode))

;; --- hl-todo: highlight TODO/FIXME/NOTE/HACK/REVIEW ------------------------
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

;; --- ligatures ---------------------------------------------------------
;; ligature.el is the non-Doom-specific package Doom's own `ligatures'
;; module is built on. The `+ligatures-extra-symbols' plist-put in
;; config.el turned OFF a handful of symbol replacements (int/float/in/
;; for/not/and/or/return/yield rendered as themselves, not ligated) -- we
;; reproduce that by simply not including those symbols below.
(use-package ligature
  :config
  (ligature-set-ligatures 'prog-mode
                           '("-->" "//" "/**" "/*" "*/" "<!--" ":=" "->>" "<<-" "->"
                             "<-" "=>" "==" "!=" "<=" ">=" "&&" "||" "::" "..." ".."
                             "|>" "<|" "??" "?." "===" "!==" "<=>"))
  (global-ligature-mode t))

;; --- minimap -------------------------------------------------------------
(use-package minimap
  :commands minimap-mode
  :config (setq minimap-window-location 'right))

;; --- ophints: highlight the region an operation acts on ---------------
;; This is `evil-goggles' in the non-Doom ecosystem -- it flashes the
;; region evil operators (delete/yank/change/...) act on, same idea as
;; Doom's ophints module.
(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

;; --- popup window management ----------------------------------------------
;; Doom's `popup' module (+defaults) auto-detects "transient" buffers
;; (compilation output, help, REPLs, ...) and displays them in a small,
;; dismissible bottom window instead of splitting your layout. `popper' is
;; the standalone package that does the same job.
(use-package popper
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*" "\\*Warnings\\*" "Output\\*$" "\\*Async Shell Command\\*"
          help-mode compilation-mode "\\*eldoc\\*"))
  (popper-mode 1)
  (popper-echo-mode 1))

;; --- unicode / vi-tilde-fringe ---------------------------------------------
;; `unicode-fonts' widens glyph coverage so symbols/emoji/CJK render instead
;; of showing boxes -- this is what Doom's `unicode' module configures.
(use-package unicode-fonts
  :config (unicode-fonts-setup))

;; Fringe tildes past end-of-buffer, like vim's `~' column. There's no
;; single drop-in package for this; it's five lines, so just inline it
;; instead of pulling in a dependency for it.
(define-fringe-bitmap 'vv-tilde-fringe [0 0 0 113 219 142 0 0])
(defun vv--vi-tilde-fringe (win)
  (with-selected-window win
    (save-excursion
      (goto-char (point-max))
      (vertical-motion 0))))
(add-hook 'window-scroll-functions #'vv--vi-tilde-fringe)

;; --- vc-gutter: VCS diff markers in the fringe ------------------------
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config (diff-hl-flydiff-mode 1))

;; --- workspaces: tab emulation + per-workspace buffer lists ---------------
;; `perspective' is the standalone equivalent of Doom's `workspaces' module
;; (which itself wraps a fork of persp-mode).
(use-package perspective
  :custom (persp-mode-prefix-key (kbd "C-c M-p"))
  :init (persp-mode 1))

(provide 'core-ui)
