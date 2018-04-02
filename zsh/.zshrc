for file in $HOME/.zsh/*.zsh; do
  source $file
done

source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz compinit promptinit
compinit
promptinit
