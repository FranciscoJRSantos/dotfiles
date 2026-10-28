;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! catppuccin-theme)

(package! auto-dark)

; (package! copilot
;   :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
; 
; (package! eca-emacs
;   :recipe (:host github :repo "editor-code-assistant/eca-emacs"))
; 
; (package! eca
;   :recipe (:host github :repo "editor-code-assistant/eca-emacs" :files ("*.el")))

;; (package! minuet)

(package! shell-maker)
(package! acp)
(package! agent-shell)

(package! agent-shell-sidebar
  :recipe (:host github :repo "cmacrae/agent-shell-sidebar" :files ("*.el")))

(package! agent-shell-manager
  :recipe (:host github :repo "jethrokuan/agent-shell-manager" :files ("*.el")))

(package! agent-shell-workspace
  :recipe (:host github :repo "gveres/agent-shell-workspace" :files ("*.el")))

(package! meta-agent-shell
  :recipe (:host github :repo "ElleNajt/meta-agent-shell" :files ("*.el")))

