;;; core-evil.el --- evil-mode + the SPC leader key -*- lexical-binding: t; -*-
;; Doom equivalent: `(evil +everywhere)' in the :editor module, plus the
;; `:config (default +bindings)' block that wires up Doom's SPC leader.
;;
;; Doom's leader-key plumbing is `map!' (a macro over `general.el' + evil +
;; which-key). Here we use `general.el' directly -- it's the same engine
;; Doom's `map!' expands into, just without the Doom-specific macro sugar.
;; `vv-leader-def' below is this config's `map! :leader' equivalent: every
;; other lisp/*.el file that wants a SPC-prefixed binding calls it.

(use-package evil
  :init
  ;; These must be set before evil loads.
  (setq evil-want-integration t
        evil-want-keybinding nil   ; evil-collection supplies bindings instead
        evil-want-C-u-scroll t     ; C-u scrolls up, like vim, instead of the emacs prefix-arg use
        evil-want-fine-undo t      ; from config.el: undo granular changes, not whole edits
        evil-undo-system 'undo-fu ; wired to core-emacs-files.el's undo-fu
        evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)
  ;; +everywhere: evil bindings even in non-editing buffers (magit, dired,
  ;; help, etc). evil-collection is exactly this -- a big library of evil
  ;; keymaps for third-party/builtin modes that don't ship their own.
  (use-package evil-collection
    :config (evil-collection-init))
  ;; Extra evil text-object/operator packages Doom's `evil +everywhere'
  ;; pulls in as part of its default keybinding scheme:
  (use-package evil-surround :config (global-evil-surround-mode 1))
  (use-package evil-commentary :config (evil-commentary-mode 1)) ; gcc to comment lines
  (use-package evil-matchit :config (global-evil-matchit-mode 1)) ; % to jump matching tags/parens
  (use-package evil-multiedit :config (evil-multiedit-default-keybinds))
  ;; Fine-grained undo, matching `evil-want-fine-undo' above.
  (setq evil-want-fine-undo t))

;; --- the SPC leader key --------------------------------------------------
(use-package general
  :after evil
  :config
  (general-create-definer vv-leader-def
    :states '(normal visual motion emacs insert)
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  ;; Top-level groups, matching Doom's own leader layout closely enough that
  ;; muscle memory mostly transfers: f=file, b=buffer, p=project, s=search,
  ;; g=git, h=help, t=toggle/terminal, o=open.
  (vv-leader-def
    ""    nil
    "SPC" '(execute-extended-command :which-key "M-x")
    "f"   '(:ignore t :which-key "file")
    "f f" '(find-file :which-key "find file")
    "f s" '(save-buffer :which-key "save file")
    "f r" '(consult-recent-file :which-key "recent files")
    "b"   '(:ignore t :which-key "buffer")
    "b b" '(consult-buffer :which-key "switch buffer")
    "b k" '(kill-current-buffer :which-key "kill buffer")
    "p"   '(:ignore t :which-key "project")
    "p p" '(project-switch-project :which-key "switch project")
    "p f" '(project-find-file :which-key "find file in project")
    "s"   '(:ignore t :which-key "search")
    "s s" '(consult-line :which-key "search buffer")
    "s p" '(consult-ripgrep :which-key "search project")
    "g"   '(:ignore t :which-key "git")
    "g g" '(magit-status :which-key "magit status")
    "h"   '(:ignore t :which-key "help")
    "h t" '(vv/load-theme :which-key "load a new theme") ; from core-theme.el, SPC h t like doom
    "t"   '(:ignore t :which-key "toggle/terminal")))

;; --- which-key: shows available bindings after a prefix key ---------------
;; This is what makes `SPC' feel discoverable instead of requiring the
;; whole leader map to be memorized up front.
(use-package which-key
  :init (which-key-mode 1)
  :config (setq which-key-idle-delay 0.4))

(provide 'core-evil)
