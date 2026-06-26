;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'semi-light))

(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'latte)

;; Disable projectile caching
(setq projectile-enable-caching nil)
(setq projectile-project-search-path '("~/Documents/projects/" "~/Documents/personal-projects/"))

(setq display-line-numbers-type t)

(setq org-directory "~/Documents/notes")

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
  (auto-dark-mode 1))

;; Python: use ruff as LSP server (linting + formatting) and ty for type checking
(defun my/find-ruff ()
  "Return project-local ruff if present, else fall back to system ruff."
  (when-let* ((root (and (project-current) (project-root (project-current))))
              (local (cl-find-if #'file-executable-p
                                 (mapcar (lambda (p) (expand-file-name p root))
                                         '(".venv/bin/ruff" "venv/bin/ruff")))))
    local))

(after! eglot
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
                 . ,(lambda (&rest _)
                      (list (or (my/find-ruff) "ruff") "server" "--preview")))))

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
