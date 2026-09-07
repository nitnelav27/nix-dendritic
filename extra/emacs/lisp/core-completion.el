;;; core-completion.el --- minibuffer + in-buffer completion -*- lexical-binding: t; -*-
;; Doom equivalent: the :completion module block (company +childframe +tng,
;; vertico +childframe +icons).

;; --- minibuffer completion: vertico + friends -----------------------------
;; vertico replaces Ivy/Helm/Ido as the minibuffer UI; orderless gives it
;; space-separated, out-of-order matching; marginalia adds the annotations
;; (file sizes, doc strings, key bindings) you'd get from Helm/Ivy for free;
;; consult and embark are the "search everything" / "act on the thing at
;; point" commands built on top.
;; Packages here come from Nix, not package.el, so there are no autoloads
;; for their mode-enabling functions. `:init' runs before the package is
;; loaded, so calling a mode function there is void-function; the fix is
;; `:config' (runs after use-package's own `require') for every direct
;; mode-enable call in this file.
(use-package vertico
  :config (vertico-mode 1))

;; +childframe: Doom renders the vertico minibuffer in a floating child
;; frame near the cursor instead of the actual minibuffer at the bottom.
;; vertico-posframe is the standalone package for exactly that.
(use-package vertico-posframe
  :after vertico
  :config (vertico-posframe-mode 1))

;; +icons: file/command icons next to each candidate.
(use-package nerd-icons-completion
  :after vertico
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config (marginalia-mode 1))

(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("C-c s g" . consult-ripgrep)))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; --- in-buffer completion: company ----------------------------------------
;; Doom kept `company' (rather than moving to the newer `corfu') as the
;; in-buffer completion backend, so we do too, with the same two flags:
;; +childframe (floating popup instead of an inline overlay, via
;; company-box) and +tng ("tab and go" -- TAB both opens and cycles the
;; popup, which is built directly into company as `company-tng-mode').
(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 2)
  (company-selection-wrap-around t)
  :config
  (company-tng-mode 1))

(use-package company-box
  :hook (company-mode . company-box-mode))

(provide 'core-completion)
