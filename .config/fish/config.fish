if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    kubectl completion fish | source

    alias doom="~/.emacs.d/bin/doom"
    alias dc="docker compose"
    alias et='emacsclient --tty'
    alias update="brew upgrade && brew update && brew cleanup -s"
    alias ibrew="arch -x86_64 /usr/local/homebrew/bin/brew"
    alias myip="curl http://ipecho.net/plain; echo"
    alias revup="z revup && zellij --layout ~/.config/zellij/revup.kdl"
    alias mdr_vpn="sudo openvpn ~/Documents/projects/mdrev/revup_vpn_confs/config3.ovpn"
end
