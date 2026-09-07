;;; lang-latex.el --- AUCTeX + CDLaTeX -*- lexical-binding: t; -*-
;; Doom equivalent: (latex +lsp +fold +cdlatex) in the :lang module.
;; texlab (the LSP server, +lsp) is already installed in
;; modules/hosts/utdt10141/programs/homePkgsUtdt10141.nix, specifically
;; because this file references it.

(use-package tex
  :ensure auctex ; the package is `auctex', the feature it provides is `tex'
  :hook ((LaTeX-mode . lsp-deferred)   ; +lsp, via texlab
         (LaTeX-mode . TeX-fold-mode)  ; +fold
         (LaTeX-mode . reftex-mode))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-PDF-mode t)
  ;; from config.el: `+latex-viewers'
  (TeX-view-program-selection '((output-pdf "Zathura"))))

;; +cdlatex: fast math-mode input (e.g. type `ee' -> \exists, `SPC' after a
;; template jumps to the next slot).
(use-package cdlatex
  :hook (LaTeX-mode . turn-on-cdlatex))

(provide 'lang-latex)
