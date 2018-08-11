for file in $HOME/.zsh/*.zsh; do
  source $file
done

source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
set rtp+=/usr/local/opt/fzf

autoload -Uz compinit promptinit
compinit
promptinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/usr/local/opt/curl/bin:$PATH"
