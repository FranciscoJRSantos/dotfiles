if status is-interactive
    set PATH /home/xicosantos/.local/bin:$PATH
    set -gx PATH $PATH $HOME/.dotnet/tools

    ### Alias
    #
    alias doom="~/.config/emacs/bin/doom"
    alias et="emacs -nw"
    alias dc="docker compose"

    ### Shell Integrations
    #
    eval $(mise activate fish | source)
    source ~/.config/fish/fzf-keybindings.fish
    eval $(zoxide init fish --cmd cd | source)
    direnv hook fish | source
end

