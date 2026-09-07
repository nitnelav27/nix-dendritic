;;; core-checkers.el --- syntax, spelling, grammar -*- lexical-binding: t; -*-
;; Doom equivalent: the :checkers module (syntax +childframe, spell
;; +enchant +flyspell +everywhere, grammar).

;; --- syntax checking ---------------------------------------------------
;; flycheck is what Doom's `syntax' module wraps. +childframe: errors shown
;; in a floating posframe instead of the echo area, via flycheck-posframe.
(use-package flycheck
  :hook (after-init . global-flycheck-mode))

(use-package flycheck-posframe
  :after flycheck
  :hook (flycheck-mode . flycheck-posframe-mode))

;; --- spell checking ------------------------------------------------------
;; +enchant: use the `enchant' spellchecking backend (multi-dictionary,
;; works well with ispell.el) instead of the default aspell/hunspell.
;; enchant-2 must be on PATH -- it's installed by Nix in emacs.nix. If your
;; apt migration already put `enchant' on this machine, this still works,
;; ispell-program-name just needs to point at whichever `enchant-2' binary
;; wins on PATH.
(setq ispell-program-name "enchant-2"
      ispell-dictionary "en_US")

(use-package flyspell
  :ensure nil
  ;; +everywhere: prose in text-mode, plus comments/strings in prog-mode.
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

;; --- grammar checking ------------------------------------------------------
;; Doom's `grammar' module shells out to LanguageTool via langtool.el. This
;; needs languagetool's server jar available locally; per the apt-migration
;; note in homePkgsUtdt10141.nix, `languagetool' doesn't have a clean apt
;; path, so this is left pointed at a placeholder -- set
;; `langtool-language-tool-jar' (or run `langtool-server-start' against a
;; jar you install yourself) before `M-x langtool-check' will work.
(use-package langtool
  :commands (langtool-check langtool-check-done langtool-correct-buffer)
  :init
  (setq langtool-default-language "en-US"
        ;; langtool-language-tool-jar "/path/to/languagetool-commandline.jar"
        ))

(provide 'core-checkers)
