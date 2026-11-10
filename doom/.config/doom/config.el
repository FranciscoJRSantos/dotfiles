;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'semi-light))

;; No doom-theme on purpose: auto-dark owns loading catppuccin, otherwise the
;; theme is applied twice on every startup (doom-theme, then auto-dark's reload).

;; Disable projectile caching
(setq projectile-enable-caching nil)
(setq projectile-project-search-path '("~/Documents/projects/" "~/Documents/personal-projects/"))

(setq display-line-numbers-type t)

(setq org-directory "~/Documents/kb-work")

(setq-default cursor-type 'bar)

(use-package auto-dark
  :config
  (setq custom-safe-themes t)
  (setq auto-dark-themes '((catppuccin) (catppuccin)))
  (add-hook 'auto-dark-dark-mode-hook
            (lambda ()
              (unless (eq catppuccin-flavor 'mocha)
                (setq catppuccin-flavor 'mocha)
                (catppuccin-reload))))
  (add-hook 'auto-dark-light-mode-hook
            (lambda ()
              (unless (eq catppuccin-flavor 'latte)
                (setq catppuccin-flavor 'latte)
                (catppuccin-reload))))
  ;; Under the daemon there is no frame when config.el loads; auto-dark's
  ;; README recommends (re)applying it once the first frame exists.
  (add-hook 'server-after-make-frame-hook
            (lambda () (auto-dark-mode 1)))
  (auto-dark-mode 1))

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
