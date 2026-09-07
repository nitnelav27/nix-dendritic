;;; early-init.el --- runs before init.el, before the UI is drawn -*- lexical-binding: t; -*-

;; This is the "emacs from scratch" replacement for Doom's bootstrap layer.
;; Nothing here depends on Doom; it's plain Emacs + a handful of packages
;; that are installed declaratively by Nix (see modules/programs/emacs.nix)
;; and already sit on `load-path' by the time this file runs.

;; --- Startup performance --------------------------------------------------
;; Emacs runs a GC cycle every time allocated memory crosses
;; `gc-cons-threshold'. During startup we raise it so GC doesn't fire
;; constantly while hundreds of packages are being loaded, then we put it
;; back to a sane (but still generous) value once startup is done, in the
;; `emacs-startup-hook' at the bottom of init.el.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; `file-name-handler-alist' is consulted on every `require'/`load' call to
;; check for magic file names (tramp, compressed files, etc). During startup
;; we're only loading local, uncompressed .el/.elc files, so temporarily
;; nil-ing it out skips that check on every single load.
(defvar vv--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; --- Package management ----------------------------------------------------
;; Packages come from Nix (emacsWithPackages in modules/programs/emacs.nix),
;; not from package.el/MELPA at runtime. Turn off Emacs' own package.el so it
;; doesn't waste time scanning ~/.emacs.d/elpa (which won't exist) or trying
;; to hit the network.
(setq package-enable-at-startup nil)

;; --- Bare UI, before the frame is even drawn --------------------------------
;; Doing this in early-init.el (rather than init.el) avoids the visible
;; "flash" of a toolbar/menu bar/scrollbar appearing and then disappearing.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t          ; we show our own dashboard instead
      inhibit-startup-echo-area-message user-login-name
      frame-inhibit-implied-resize t)   ; don't resize the frame on font/theme changes

;; Prevent a resize flash when the first real frame is created (theme/font
;; get set in lisp/theme-personal.el, which then resizes the frame anyway).
(setq frame-resize-pixelwise t)
