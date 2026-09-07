;;; core-tools.el --- eval, lookup, lsp-mode, magit, pdf-tools, rainbow -*- lexical-binding: t; -*-
;; Doom equivalent: the :tools module (eval +overlay, lookup +dictionary
;; +offline, lsp +peek, magit, pdf, rgb).

;; --- eval: run code and show the result inline ----------------------------
;; +overlay: Doom shows eval results as an overlay next to the sexp instead
;; of only in the echo area. `eros' does exactly this for elisp;
;; `quickrun' covers "run this file/region in its own language" for
;; everything else (python, sh, etc).
(use-package eros
  :hook (emacs-lisp-mode . eros-mode))

(use-package quickrun
  :commands quickrun)

;; --- lookup: docs and dictionary, without leaving Emacs ---------------
;; +dictionary +offline: Doom's `lookup' module can define words via a
;; local dictionary server instead of a web lookup. `dictionary.el' ships
;; with Emacs and talks to a local `dictd'/`dict' server (Nix installs
;; `dictd' + a wordnet dictionary in emacs.nix); `define-word' is a
;; lighter-weight fallback that also works offline against `wordnet' data.
(use-package dictionary
  :ensure nil
  :commands (dictionary-search dictionary-lookup-definition)
  :custom (dictionary-server "localhost"))

(use-package define-word
  :commands (define-word define-word-at-point))

;; xref (built-in) + lsp/eglot below cover "jump to definition/references",
;; which is the other half of Doom's `lookup' module.

;; --- lsp-mode: language server integration ----------------------------
;; +peek: lsp-ui's "peek" windows (definitions/references shown inline
;; without switching buffers) instead of jumping away immediately.
(use-package lsp-mode
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :commands lsp
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-headerline-breadcrumb-enable t))

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-peek-enable t)) ; the +peek flag

;; --- magit -----------------------------------------------------------------
(use-package magit
  :commands magit-status
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; --- pdf-tools ---------------------------------------------------------
(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-page))

;; --- rgb: colorize color strings (#rrggbb, rgb(), color names) -----------
(use-package rainbow-mode
  :hook ((prog-mode css-mode) . rainbow-mode))

(provide 'core-tools)
