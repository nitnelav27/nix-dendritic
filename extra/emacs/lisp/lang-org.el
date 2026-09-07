;;; lang-org.el --- org-mode, agenda, citations, LaTeX export, roam -*- lexical-binding: t; -*-
;; Doom equivalent: (org +gnuplot +hugo +pandoc +present +roam2 +pretty) in
;; the :lang module, plus every "ORG mode" section of config.el/config.org.
;; This is the single biggest file here on purpose -- config.el's own
;; comment calls org "the main reason to use Emacs."

(use-package org
  :ensure nil ; built into Emacs; the `org' ELPA package below tracks upstream more closely
  :hook (org-mode . org-indent-mode)
  :config
  ;; --- from config.el's `(after! org ...)' block -------------------------
  (setq org-ellipsis " ▼ "
        org-hide-emphasis-markers t
        org-agenda-files (list (expand-file-name "agenda/agenda.org" vv-emacs-dir)
                                (expand-file-name "agenda/weekly.org" vv-emacs-dir))
        org-log-done 'time
        org-todo-keywords
        '((sequence "TODO(t)" "READ(r)" "TEACH(e)" "MEETING(m)" "|" "DONE(d)"))
        ;; +pretty
        org-pretty-entities t)

  ;; PDF opener, OS-conditional exactly like config.el.
  (setq org-file-apps
        (cond ((eq system-type 'gnu/linux) '((".pdf" . "zathura %s")))
              ((eq system-type 'darwin)    '((".pdf" . "Preview.app %o")))))

  ;; --- LaTeX export (the two big blocks from config.el) -------------------
  (setq org-latex-pdf-process
        '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "bibtex %b"
          "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f")

        org-latex-default-packages-alist
        '(("utf8" "inputenc" t ("pdflatex"))
          ("" "graphicx" t) ("" "wrapfig" t) ("" "rotating" t) ("" "grffile" t)
          ("normalem" "ulem" t) ("" "amsmath" t) ("" "amssymb" t) ("" "capt-of" t))

        org-latex-packages-alist
        '(("dvipsnames" "xcolor")
          ("colorlinks=true,breaklinks=true,citecolor=cyan,urlcolor=blue" "hyperref")
          ("" "natbib") ("" "float") ("" "ragged2e") ("" "tabularx")
          ("" "subcaption") ("" "mdframed"))

        ;; `listings' syntax highlighting for exported code blocks (the
        ;; `minted' alternative from config.org stays commented out, same
        ;; as the original -- uncomment and swap `org-latex-listings' to
        ;; 'minted plus `org-latex-minted-options' if you want it back).
        org-latex-listings 'listings
        org-latex-listings-options
        '(("frame" "single")
          ("backgroundcolor" "\\color{define}")
          ("commentstyle" "\\color{codegreen}")
          ("keywordstyle" "\\color{magenta}")
          ("stringstyle" "\\color{codepurple}")
          ("basicstyle" "\\linespread{0.9}\\fontsize{9}{12}\\selectfont\\ttfamily")
          ("breakatwhitespace" "false")
          ("breaklines" "true")
          ("captionpos" "b")
          ("keepspaces" "true")
          ("numbers" "left")
          ("numberstyle" "\\tiny\\color{gray}")
          ("numbersep" "5pt")
          ("showspaces" "false")
          ("showstringspaces" "false")
          ("showtabs" "false")
          ("tabsize" "4")))

  ;; +gnuplot: `gnuplot' org-babel language + the elisp gnuplot-mode.
  (add-to-list 'org-babel-load-languages '(gnuplot . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))

;; +pretty: org-superstar redraws `*' headline stars as clean bullets/icons
;; -- the visual half of Doom's `+pretty' flag (the other half,
;; `org-hide-emphasis-markers', is set above).
(use-package org-superstar
  :hook (org-mode . org-superstar-mode))

;; +gnuplot: the elisp side (plotting support inside org-babel results).
(use-package gnuplot :after org)

;; +hugo: export org subtrees/files as Hugo-flavored markdown posts.
(use-package ox-hugo :after ox)

;; +pandoc: export via pandoc to whatever pandoc itself supports.
(use-package ox-pandoc :after ox)

;; +present: `org-tree-slide' turns an org outline into a slide deck.
(use-package org-tree-slide
  :commands org-tree-slide-mode
  :custom (org-tree-slide-slide-in-effect nil))

;; --- org-ref: BibTeX/DOI/arXiv citation support -----------------------
;; org-ref's own repo bundles org-ref-bibtex, doi-utils, org-ref-arxiv and
;; org-ref-isbn (packages.el listed them separately because Doom's package
;; manager pins per-file; the Nix `org-ref' derivation already includes
;; all of them, so one `use-package' block covers what used to be five).
(use-package org-ref
  :after org
  :init
  (setq org-ref-default-bibliography '("~/.local/references/master.bib")
        org-ref-bibliography-notes '("~/.local/references/notes.org")
        reftex-default-bibliography '("~/.local/references/master.bib")
        bibtex-completion-bibliography '("~/.local/references/master.bib")
        reftex-bibpath-environment-variables '("~/.local/references/master.bib")))

;; --- org-roam (+roam2) -----------------------------------------------------
;; config.el/config.org both gate org-roam behind `(eq system-type 'darwin)'
;; -- ported verbatim; remove the `:if' below if you want roam on Linux too.
(use-package org-roam
  :if (eq system-type 'darwin)
  :init
  (setq org-roam-directory "~/.local/references/roam"
        org-roam-graph-executable "/usr/bin/dot")
  :config (org-roam-db-autosync-mode))

(setq orb-insert-interface 'helm-bibtex
      orb-insert-link-description 'citekey
      orb-autokey-format "%A%y"
      orb-templates
      '(("r" "ref" plain (function org-roam-capture--get-point) ""
         :file-name "${citekey}"
         :head "#+TITLE: ${citekey}: ${title}\n#+ROAM_KEY: ${ref}\n#+ALIAS:\n"
         :unnarrowed t)))

(use-package org-roam-bibtex
  :after (org-roam org-ref)
  :hook (org-roam-mode . org-roam-bibtex-mode))

(provide 'lang-org)
