;;; core-editor.el --- snippets, folding, word-wrap, smartparens -*- lexical-binding: t; -*-
;; Doom equivalent: the rest of the :editor module (file-templates, fold,
;; snippets, word-wrap) and `:config (default +smartparens)'.

;; --- snippets --------------------------------------------------------------
;; yasnippet is what Doom's `snippets' module wraps; doom-snippets was the
;; bundled snippet library. We keep your own hand-written snippets (copied
;; from $DOOMDIR/snippets into ./snippets alongside this config) and add
;; the community yasnippet-snippets collection instead of doom-snippets,
;; since the latter is Doom-specific and pulled in via Doom's own package
;; manager.
(use-package yasnippet
  :hook (after-init . yas-global-mode)
  :config
  (setq yas-snippet-dirs (list (expand-file-name "snippets" vv-emacs-dir))))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package auto-yasnippet
  :after yasnippet)

;; --- file templates ---------------------------------------------------
;; Doom's `file-templates' module auto-inserts a snippet when you open an
;; empty file matching a pattern (e.g. a new .el file gets a header
;; comment). Plain Emacs' built-in `autoinsert' does the same job; wiring
;; it to yasnippet templates gets you the exact Doom-style behavior.
(use-package autoinsert
  :ensure nil
  :hook (find-file . auto-insert)
  :config
  (setq auto-insert-query nil)
  (define-auto-insert "" [yas-expand]))

;; --- folding -----------------------------------------------------------
;; hideshow is built into Emacs and covers "(nigh) universal code folding"
;; via indentation/braces; evil-collection (core-evil.el) already gives it
;; the vim `za'/`zo'/`zc' bindings.
(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode))

;; --- word-wrap: soft wrapping with language-aware indent -------------------
(use-package adaptive-wrap
  :hook (visual-line-mode . adaptive-wrap-prefix-mode))
(add-hook 'text-mode-hook #'visual-line-mode)

;; --- smartparens ---------------------------------------------------------
;; Doom enables this via `:config (default +smartparens)'. Auto-pairs and
;; auto-balances brackets/quotes.
(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :config (require 'smartparens-config))

(provide 'core-editor)
