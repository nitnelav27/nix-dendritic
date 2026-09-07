;;; email.el --- mu4e (+gmail) -*- lexical-binding: t; -*-
;; Doom equivalent: (mu4e +gmail) in the :email module.
;;
;; mu4e only reads/searches mail that's already synced to local Maildir --
;; it is NOT a fetcher itself. Doom's `+gmail' flag just adds a couple of
;; Gmail-specific IMAP folder/flag conventions to mu4e; the actual syncing
;; (mbsync/isync or offlineimap, talking to Gmail over IMAP with an app
;; password or OAuth2 token) is a separate piece Doom would have quietly
;; assumed was already set up. It genuinely isn't safe for me to invent
;; your Gmail credentials or write an mbsyncrc with them, so this block
;; only wires up the Emacs side -- fill in `user-mail-address' below (or
;; leave the profile default) and add an `~/.mbsyncrc' (or an
;; `age'/`agenix'-managed one, given secrets.nix already exists in this
;; repo for exactly this kind of thing) before `mu4e' will show real mail.

(use-package mu4e
  ;; mu4e ships inside the `mu' Nix package's share/emacs/site-lisp; Nix
  ;; puts that on load-path in emacs.nix, so no `:ensure'/`:load-path' is
  ;; needed here as long as that module is applied.
  :ensure nil
  :commands mu4e
  :init
  (setq mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval (* 10 60)
        mu4e-maildir "~/Maildir"
        mu4e-change-filenames-when-moving t ; required for mbsync
        ;; +gmail: Gmail's IMAP presents "All Mail"/"Sent Mail"/"Trash" as
        ;; special folders with their own semantics (e.g. don't re-upload
        ;; a sent message, Gmail already puts it in Sent Mail itself).
        mu4e-sent-messages-behavior 'delete
        mu4e-drafts-folder "/[Gmail].Drafts"
        mu4e-sent-folder   "/[Gmail].Sent Mail"
        mu4e-trash-folder  "/[Gmail].Trash"
        mu4e-refile-folder "/[Gmail].All Mail")
  (setq user-mail-address "valentinvergara@gmail.com"))

(provide 'email)
