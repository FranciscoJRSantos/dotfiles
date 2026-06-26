if status is-interactive
    set PATH $HOME/.local/bin:$HOME/bin:$HOME/Documents/personal-projects/meta-agent-shell/bin:$PATH

    set -Ux EMACS_USE_XDG 1
    set -gx EDITOR nvim

    ### Alias
    #
    alias doom="~/.config/emacs/bin/doom"
    alias et="emacs -nw"
    alias dc="docker compose"

    ### Shell Integrations
    eval $(mise activate fish | source)
    source ~/.config/fish/fzf-keybindings.fish
    eval $(zoxide init fish --cmd cd | source)
    direnv hook fish | source
end

