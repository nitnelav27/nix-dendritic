;;; keybindings.el --- leader-key bindings that don't belong to one module -*- lexical-binding: t; -*-
;; core-evil.el defines `vv-leader-def' (the SPC leader) and the top-level
;; groups; this file adds the handful of leaf bindings config.el itself
;; defined with `map!' outside of any particular Doom module -- kept
;; separate so it's obvious this is "your" bindings, not a module's.

;; From config.el: `SPC t t' opens a vterm.
(vv-leader-def "t t" '(vterm :which-key "open vterm"))

;; `SPC h t' (load a new theme) is defined in core-theme.el, right next to
;; `vv/load-theme' itself, and registered on `vv-leader-def' in
;; core-evil.el -- listed here just so this file is a complete map of
;; "where are my keybindings", per Doom's own `:config (default +bindings)'.

(provide 'keybindings)
