;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! catppuccin-theme)

(package! auto-dark)

;; (package! minuet)

(package! shell-maker)
(package! acp)
(package! agent-shell)

(package! agent-shell-sidebar
  :recipe (:host github :repo "cmacrae/agent-shell-sidebar" :files ("*.el")))

(package! agent-shell-manager
  :recipe (:host github :repo "jethrokuan/agent-shell-manager" :files ("*.el")))

