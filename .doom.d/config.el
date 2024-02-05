;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Francisco Santos"
      user-mail-address "francisco.santos@redlightsoft.com")

(pixel-scroll-precision-mode t)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Hack Nerd Font" :size 14))
;;      doom-variable-pitch-font (font-spec :family "sans" :size 24))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-monokai-pro)
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'macchiato)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/notes/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; asdf.el
(require 'asdf)
(asdf-enable)

;; Copilot.el
; complete by copilot first, then company-mode
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-accept-completion)
         ("C-<tab>" . 'copilot-accept-completion)
         ("S-<iso-lefttab>" . 'copilot-next-completion)
         ("<backtab>" . 'copilot-next-completion)
         ))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(after! projectile
  (setq projectile-generic-command
      (lambda (_)
        ;; If fd exists, use it for git and generic projects. fd is a rust
        ;; program that is significantly faster than git ls-files or find, and
        ;; it respects .gitignore. This is recommended in the projectile docs.
        (cond
         ((when-let
              (bin (if (ignore-errors (file-remote-p default-directory nil t))
                       (cl-find-if (doom-rpartial #'executable-find t)
                                   (list "fdfind" "fd"))
                     doom-projectile-fd-binary))
            (concat (format "%s . -0 -H --color=never --type file --no-follow --exclude .git"
                            bin)
                    (if IS-WINDOWS " --path-separator=/"))))
         ;; Otherwise, resort to ripgrep, which is also faster than find
         ((executable-find "rg" t)
          (concat "rg -0 --files --no-follow --color=never --hidden -g!.git"
                  (if IS-WINDOWS " --path-separator=/")))
         ("find . -type f -print0")))))

;; Disable the annoying projectile cache...
(setq projectile-enable-caching nil)

;; Magit - Enable Gravatars
(setq magit-revision-show-gravatars '("^Author:     " . "^Commit:     "))

;; Mermaid.js
(setq ob-mermaid-cli-path "/opt/homebrew/bin/mmdc")

(org-babel-do-load-languages
    'org-babel-load-languages
    '((mermaid . t)))

;; Set a debounce time (in seconds) before Flycheck starts linting
(setq flycheck-idle-change-delay 1)

;; Set a debounce time (in seconds) before LSP checks for changes
(after! lsp-mode
  (setq lsp-idle-delay 1))

;; Tiling Emacs
(menu-bar-mode t)
