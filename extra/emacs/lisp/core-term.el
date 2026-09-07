;;; core-term.el --- eshell, shell, term, vterm -*- lexical-binding: t; -*-
;; Doom equivalent: the :term module. eshell/shell/term are all built into
;; Emacs already; only vterm needs a real package (it wraps libvterm, a C
;; library, via a dynamic module -- built by Nix, see modules/programs/emacs.nix).

(use-package eshell
  :ensure nil
  :commands eshell)

(use-package shell
  :ensure nil
  :commands shell)

(use-package term
  :ensure nil
  :commands term)

;; config.org/config.el's own comment history is honest about this: eshell
;; was the original plan, but vterm ("looks exactly like my usual terminal
;; emulator") is what's actually bound to SPC t t -- see keybindings.el.
(use-package vterm
  :commands vterm
  :custom (vterm-max-scrollback 5000))

(provide 'core-term)
