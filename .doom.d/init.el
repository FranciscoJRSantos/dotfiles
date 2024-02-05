;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a "Module Index" link where you'll find
;;      a comprehensive list of Doom's modules and what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :input
       ;;chinese
       ;;japanese
       ;;layout                         ; auie,ctsrnm is the superior home row

       :completion
       (company +childframe)            ; the ultimate code completion backend
       ;;(ivy +prescient +icons)        ; a search engine for love and life
       ;;helm                           ; the *other* search engine for love and life
       ;;ido                            ; the other *other* search engine...
       (vertico +icons)

       :ui
       doom                             ; what makes DOOM look the way it does
       doom-dashboard                   ; a nifty splash screen for Emacs
       doom-quit                        ; DOOM quit-message prompts when you quit Emacs
       (emoji +unicode +github)         ; 🙂
       hl-todo                          ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides                    ; highlighted indent columns
       ligatures                        ; ligatures and symbols to make your code pretty again
       (modeline +light)                ; snazzy, Atom-inspired modeline, plus API
       nav-flash                        ; blink cursor line after big motions
       ophints                          ; highlight the region an operation acts on
       (popup +defaults)                ; tame sudden yet inevitable temporary windows
       unicode                          ; extended unicode support for various languages
       (vc-gutter +pretty)              ; vcs diff in the fringe
       vi-tilde-fringe                  ; fringe tildes to mark beyond EOB
       window-select                    ; visually switch windows
       workspaces                       ; tab emulation, persistence & separate workspaces
       ;;treemacs                         ; a project drawer, like neotree but cooler
       ;;deft                           ; notational velocity for Emacs
       ;;fill-column                    ; a `fill-column' indicator
       ;;hydra
       ;;minimap                        ; show a map of the code on the side
       ;;neotree                        ; a project drawer, like NERDTree for vim
       ;;tabs                           ; a tab bar for Emacs
       zen                              ; distraction-free coding or writing

       :editor
       (evil +everywhere)               ; come to the dark side, we have cookies
       fold                             ; (nigh) universal code folding
       word-wrap                        ; soft wrapping with language-aware indent
       rotate-text                      ; cycle region at point between text candidates
       ;snippets                        ; my elves. They type so I don't have to
       ;file-templates                  ; auto-snippets for empty files
       ;;(format +onsave)               ; automated prettiness
       ;;god                            ; run Emacs commands without modifier keys
       ;;lispy                          ; vim for lisp, for people who don't like vim
       ;;multiple-cursors               ; editing in many places at once
       ;;objed                          ; text object editing for the innocent
       ;;parinfer                       ; turn lisp into python, sort of

       :emacs
       (dired +icons)                   ; making dired pretty [functional]
       electric                         ; smarter, keyword-based electric-indent
       (ibuffer +icons)                 ; interactive buffer management
       (undo +tree)                     ; persistent, smarter undo for your inevitable mistakes
       vc                               ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell                         ; the elisp shell that works everywhere
       ;;shell                          ; simple shell REPL for Emacs
       ;;term                           ; basic terminal emulator for Emacs
       vterm                            ; the best terminal emulation in Emacs

       :checkers
       (syntax +childframe)             ; tasing you for every semicolon you forget
       ;;(spell +flyspell)                ; tasing you for misspelling mispelling
       ;;grammar                        ; tasing grammar mistake every you make

       :tools
       debugger                         ; FIXME stepping through code, to help you add bugs
       (docker +lsp)
       editorconfig                     ; let someone else argue about tabs vs spaces
       (eval +overlay)                  ; run code, run (also, repls)
       lookup                           ; navigate your code and its documentation
       (magit +forge)                   ; a git porcelain for Emacs
       make                             ; run make tasks from Emacs
       pdf                              ; pdf enhancements
       (terraform +lsp)                 ; infrastructure as code
       tree-sitter
       (lsp +peek)                      ; M-x vscode
       ;;ansible
       ;;direnv
       ;;ein                            ; tame Jupyter notebooks with emacs
       ;;gist                           ; interacting with github gists
       ;;pass                           ; password manager for nerds
       ;;prodigy                        ; FIXME managing external services & code builders
       ;;tmux                           ; an API for interacting with tmux
       ;;upload                         ; map local to remote projects via ssh/ftp

       :os
       (:if IS-MAC macos)               ; improve compatibility with macOS
       tty                              ; improve the terminal Emacs experience

       :lang
       emacs-lisp                       ; drown in parentheses
       (json +lsp +tree-sitter)         ; At least it ain't XML
       (javascript +lsp +tree-sitter)   ; all(hope(abandon(ye(who(enter(here))))))
       markdown                         ; writing docs for people to ignore
       (org +pretty)                    ; organize your plain life in plain text
       (rest +jq)                       ; Emacs as a REST client
       (ruby +rails +rbenv +tree-sitter); 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       (sh +tree-sitter)                ; she sells {ba,z,fi}sh shells on the C xor
       (web +tree-sitter)               ; the tubes
       (yaml +tree-sitter)              ; JSON, but readable
       data                             ; config/data formats
       ;;(csharp +dotnet)               ; unity, .NET, and mono shenanigans
       ;;(go +tree-sitter)              ; the hipster dialect
       ;; (cc +tree-sitter)             ; C > C++ == 1
       ;;purescript                     ; javascript, but functional
       ;;agda                           ; types of types of types of types...
       ;;beancount                      ; mind the GAAP
       ;;clojure                        ; java with a lisp
       ;;common-lisp                    ; if you've seen one lisp, you've seen them all
       ;;coq                            ; proofs-as-programs
       ;;crystal                        ; ruby at the speed of c
       ;;(dart +flutter)                ; paint ui and not much else
       ;;elixir                         ; erlang done right
       ;;elm                            ; care for a cup of TEA?
       ;;erlang                         ; an elegant language for a more civilized age
       ;;ess                            ; emacs speaks statistics
       ;;factor
       ;;faust                          ; dsp, but you get to keep your soul
       ;;fsharp                         ; ML stands for Microsoft's Language
       ;;fstar                          ; (dependent) types and (monadic) effects and Z3
       ;;gdscript                       ; the language you waited for
       ;;(haskell +dante)               ; a language that's lazier than I am
       ;;hy                             ; readability of scheme w/ speed of python
       ;;idris                          ; a language you can depend on
       ;;(java +meghanada)              ; the poster child for carpal tunnel syndrome
       ;;julia                          ; a better, faster MATLAB
       ;;kotlin                         ; a better, slicker Java(Script)
       ;;latex                          ; writing papers in Emacs has never been so fun
       ;;lean                           ; for folks with too much to prove
       ;;ledger                         ; be audit you can be
       ;;lua                            ; one-based indices? one-based indices
       ;;nim                            ; python + lisp at the speed of c
       ;;nix                            ; I hereby declare "nix geht mehr!"
       ;;ocaml                          ; an objective camel
       ;;php                            ; perl's insecure younger brother
       ;;plantuml                       ; diagrams for confusing people more
       ;;python                         ; beautiful is better than ugly
       ;;qt                             ; the 'cutest' gui framework ever
       ;;racket                         ; a DSL for DSLs
       ;;raku                           ; the artist formerly known as perl6
       ;;rst                            ; ReST in peace
       ;;rust                           ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scala                          ; java, but good
       ;; (scheme +racket)                 ; a fully conniving family of lisps
       ;;sml
       ;;solidity                       ; do you need a blockchain? No.
       ;;swift                          ; who asked for emoji variables?
       ;;terra                          ; Earth and Moon in alignment for performance.
       ;;zig                            ; C, but simpler

       :email
       ;;(mu4e +gmail +org)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       calendar
       ;;emms
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       (rss +org)          ; emacs as an RSS reader
       ;;twitter           ; twitter client https://twitter.com/vnought

       :config
       (default +bindings))
       ;;literate
