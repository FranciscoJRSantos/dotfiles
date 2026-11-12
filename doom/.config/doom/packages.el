;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! auto-dark)

;; PR-style branch review over Magit. Young (2026), so pinned: bump the pin
;; deliberately after reading upstream's log.
(package! diff-review
  :recipe (:host github :repo "xiaoxinghu/diff-review"
           :files ("diff-review.el" "diff-review-magit.el"))
  :pin "49cba292bb933e2a1a90f61145e29311636544ae")
