;;; lang-prog.el --- programming language modes -*- lexical-binding: t; -*-
;; Doom equivalent: (cc +lsp), data, emacs-lisp, ess, json, lua, markdown,
;; (nix +lsp), (python +lsp +cython +pyright), (sh +lsp), (swift +lsp),
;; (yaml +lsp) in the :lang module block.
;;
;; LSP servers themselves (nil/nixd, pyright, bash-language-server,
;; clangd, yaml-language-server) are installed by Nix -- pyright and nil
;; already come from modules/hosts/utdt10141/programs/nixTools.nix; the
;; rest are added in modules/programs/emacs.nix. Each block below just
;; tells lsp-mode which server to expect, or relies on lsp-mode's own
;; built-in server registry (which already knows most of these by name).

;; --- emacs-lisp --------------------------------------------------------
;; Nothing to install; just some quality-of-life hooks.
(add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)

;; --- nix ---------------------------------------------------------------
(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . lsp-deferred)
  ;; nixTools.nix installs `nil' as the nix LSP server; lsp-mode already
  ;; knows how to launch `nil' for nix-mode, no extra registration needed.
  )

;; --- python (+lsp +cython +pyright) --------------------------------
(use-package python
  :ensure nil
  :hook (python-mode . lsp-deferred)
  :custom (python-shell-interpreter "python3"))

;; +pyright: lsp-mode defaults to pyright automatically when it's on PATH
;; (nixTools.nix already installs it); `lsp-pyright' just adds richer
;; pyright-specific settings/UI on top of the generic lsp-mode client.
(use-package lsp-pyright
  :after lsp-mode
  :custom (lsp-pyright-multi-root nil))

;; +cython: .pyx buffers get python-like syntax highlighting.
(use-package cython-mode
  :mode "\\.pyx\\'")

;; --- sh (+lsp) -----------------------------------------------------------
(use-package sh-script
  :ensure nil
  :hook (sh-mode . lsp-deferred)
  ;; lsp-mode's built-in `sh-mode' client shells out to
  ;; `bash-language-server', installed in emacs.nix.
  )

;; --- cc (+lsp): C / C++ / Obj-C --------------------------------------
(use-package cc-mode
  :ensure nil
  :hook ((c-mode c++-mode objc-mode) . lsp-deferred)
  ;; lsp-mode's cc client uses clangd, installed in emacs.nix.
  )

;; --- data: config/data formats -------------------------------------------
(use-package json-mode :mode "\\.json\\'")
(use-package toml-mode :mode "\\.toml\\'")

;; --- yaml (+lsp) -----------------------------------------------------------
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :hook (yaml-mode . lsp-deferred)
  ;; lsp-mode's yaml client uses yaml-language-server, installed in emacs.nix.
  )

;; --- lua -------------------------------------------------------------------
(use-package lua-mode :mode "\\.lua\\'")

;; --- markdown --------------------------------------------------------
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc")) ; pandoc is already an apt package here

;; --- ess: Emacs Speaks Statistics (R) ------------------------------------
(use-package ess
  :commands R
  :init (setq ess-ask-for-ess-directory nil))

;; --- swift (+lsp) ----------------------------------------------------------
;; sourcekit-lsp realistically only exists on macOS (it ships with the
;; Swift toolchain); the hook is harmless on Linux, lsp-mode simply won't
;; find a server to start.
(use-package swift-mode
  :mode "\\.swift\\'"
  :hook (swift-mode . lsp-deferred))

(provide 'lang-prog)
