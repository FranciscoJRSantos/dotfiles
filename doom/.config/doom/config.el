;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 16 :weight 'semi-light))

(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'latte)

;; Disable projectile caching
(setq projectile-enable-caching nil)
(setq projectile-project-search-path '("~/Documents/projects/" "~/Documents/personal-projects/"))

(setq display-line-numbers-type t)

(setq org-directory "~/Documents/notes")

(setq-default cursor-type 'bar)

(setq lsp-idle-delay 0.5) ; 500ms

(use-package auto-dark
  :ensure t
  :config
  (setq custom-safe-themes t)
  (ignore-errors
    (setq auto-dark-themes '((catppuccin) (catppuccin)))

    (add-hook 'auto-dark-dark-mode-hook
              (lambda ()
                (setq catppuccin-flavor 'mocha)
                (catppuccin-reload)))

    (add-hook 'auto-dark-light-mode-hook
              (lambda ()
                (setq catppuccin-flavor 'latte)
                (catppuccin-reload)))

    (auto-dark-mode 1)))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("C-f" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))



(use-package! gptel
 :config
 (setq gptel-model 'gtp-4o
       gptel-backend (gptel-make-gh-copilot "Copilot"))
 (gptel-make-preset 'programming
   :description "Help with programming tasks"
   :backend (gptel-make-gh-copilot "Copilot")
   :model 'gpt-4o
   :system "You are an expert coding assistant. Your role is to provide high-quality code solutions, refactorings, and explanations."
 ))


(use-package! ob-mermaid
  :after org
  :config
  (setq ob-mermaid-cli-path "mmdc")
  (add-to-list 'org-babel-load-languages '(mermaid . t)))
