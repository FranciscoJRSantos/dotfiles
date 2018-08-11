#------------------------------
# History stuff
#------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

#------------------------------
# Variables
#------------------------------
export BROWSER="firefox"
export EDITOR="nvim"
export ZSH=/Users/franciscosantos/.oh-my-zsh
export TERM=xterm-256color
export SSH_KEY_PATH="~/.ssh/rsa_id"

#------------------------------
# Theme Related
#------------------------------
ZSH_THEME="common"
COMPLETION_WAITING_DOTS="true"
(cat ~/.cache/wal/sequences &) 

#------------------------------
# Plugins
#------------------------------
plugins=(
  git
  fast-syntax-highlighting
  zsh-autosuggestions
)

#------------------------------
# Path
#------------------------------
export PATH="/usr/local/bin:$PATH"

#------------------------------
# Other
#------------------------------
DISABLE_UNTRACKED_FILES_DIRTY="true"
ENABLE_CORRECTION="true"

