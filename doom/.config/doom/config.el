;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'semi-light))

;; No doom-theme on purpose: auto-dark owns loading the theme, otherwise it is
;; applied twice on every startup (doom-theme, then auto-dark's reload).

;; Theme: Noctalia renders `themes/noctalia-theme.el` from its current palette
;; (the built-in "emacs" template, enabled in Noctalia's settings). The file is
;; rewritten on every scheme change, so it is generated output and stays out of
;; the repo; only this wiring is tracked. auto-dark's hooks re-read the file so
;; a light/dark switch picks up the freshly rendered colours.
(add-to-list 'custom-theme-load-path (expand-file-name "themes" doom-user-dir))

(defun +noctalia-apply-theme ()
  "Re-read the Noctalia-rendered theme file and apply it."
  (interactive)
  (let ((file (expand-file-name "themes/noctalia-theme.el" doom-user-dir)))
    (when (file-exists-p file)
      (load-file file)
      (load-theme 'noctalia t))))

;; Disable projectile caching
(setq projectile-enable-caching nil)
(setq projectile-project-search-path '("~/Documents/projects/" "~/Documents/personal-projects/"))

(setq display-line-numbers-type t)

(setq org-directory "~/Documents/kb-work")

(setq-default cursor-type 'bar)

(use-package auto-dark
  :config
  (setq custom-safe-themes t)
  (setq auto-dark-themes '((noctalia) (noctalia)))
  (add-hook 'auto-dark-dark-mode-hook #'+noctalia-apply-theme)
  (add-hook 'auto-dark-light-mode-hook #'+noctalia-apply-theme)
  ;; Under the daemon there is no frame when config.el loads; auto-dark's
  ;; README recommends (re)applying it once the first frame exists.
  (add-hook 'server-after-make-frame-hook
            (lambda () (auto-dark-mode 1)))
  (auto-dark-mode 1)
  (+noctalia-apply-theme))

;; Python: ty is the LSP (completion, hover, go-to-definition). ruff only
;; formats, through apheleia below.
(after! eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("ty" "server"))))

;; Use ruff for formatting Python buffers via apheleia
(after! apheleia
  (setf (alist-get 'python-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff))


(after! org-tree-slide
  ;; Show #+TITLE / #+AUTHOR as a persistent header on every slide
  (setq org-tree-slide-header t)
  ;; Don't skip any outline levels — all * headings are slides
  (setq org-tree-slide-skip-outline-level 0)
  (setq +org-present-text-scale 3)
  ;; Skip COMMENT-tagged and DONE headings
  (setq org-tree-slide-skip-comments t)
  (setq org-tree-slide-skip-done t))

;; diff-review: PR-style review of a branch (`M-x diff-review-branch', or `d v'
;; in Magit's diff menu). The review is JSON under .git/review/, never committed,
;; so agents can leave comments in it with jq. Everything else is under the
;; package's `C-c _' prefix; the README's other Evil keys clash with
;; evil-nerd-commenter (gc), fold (zf, zd) and evil-lion (gl).
(use-package! diff-review
  :defer t
  :hook ((diff-review-mode diff-review-sidebar-mode) . hl-line-mode)
  :init
  (after! magit (diff-review-magit-mode))
  :config
  ;; Same muscle memory as Doom's ]d/[d (git hunks) and ]c/[c (comments).
  (map! :map diff-review-file-mode-map
        :n "]d" #'diff-review-next-hunk
        :n "[d" #'diff-review-previous-hunk
        :n "]c" #'diff-review-next-comment
        :n "[c" #'diff-review-previous-comment))
