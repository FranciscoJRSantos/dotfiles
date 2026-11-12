if status is-interactive
    # Idempotent: fish_add_path skips entries already present and persists them,
    # so nested shells no longer stack duplicate PATH entries.
    fish_add_path -g $HOME/.local/bin $HOME/bin $HOME/.opencode/bin

    set -gx EDITOR nvim

    ### Alias
    #
    alias doom="~/.config/emacs/bin/doom"
    # Attach to the Emacs daemon; only cold-start it as a fallback.
    alias et="emacsclient -t -a ''"
    abbr --add dc "docker compose"

    ### Shell Integrations
    mise activate fish | source
    fzf --fish | source
    zoxide init fish --cmd cd | source
    direnv hook fish | source

    ### Sandboxed OpenCode
    # Launch OpenCode inside a nono sandbox (credential isolation, network allowlist).
    # Plain `opencode` remains unsandboxed for system admin tasks (dotfiles, monitors, etc.).
    #
    # Note: --standalone mode uses port 0 (random port) which is blocked by nono on Linux.
    # The sandbox-opencode script starts the server explicitly on port 4096, then connects the TUI to it.
    function sandbox
        sandbox-opencode $argv
    end
end
