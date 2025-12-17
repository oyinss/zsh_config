#!/bin/zsh

# ███ █ █ ███ ███ ███ ███ ███
# █   █ █ █ █ █ █ █ █  █  █
# ███  █  ███ █ █ ██   █   █
# █   █ █ █   █ █ █ █  █    █
# ███ █ █ █   ███ █ █  █  ███

export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="vivaldi"
export PATH="$HOME/.local/bin":$PATH
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/share/go/bin:$PATH
export GOPATH=$HOME/.local/share/go
export PATH="$HOME/.local/share/neovim/bin":$PATH
export XDG_CURRENT_DESKTOP="Wayland"
eval "$(zoxide init zsh)"
export PATH="$HOME/.local/bin":$PATH

# -------------------------------------------------------
# Foundry setup
# -------------------------------------------------------
export PATH="$PATH:/home/$USER/.foundry/bin"

# -------------------------------------------------------
# export kvantum
# -------------------------------------------------------
export QT_QPA_PLATFORMTHEME="kvantum"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# -------------------------------------------------------
# Function to load environment variables
# -------------------------------------------------------
load_environment() {
  if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
  else
    echo "Warning: $ENV_FILE not found. Consider creating it with your environment variables." >&2
  fi
}

load_environment

# -------------------------------------------------------
# SSH Alias for Kitty Terminal: 
# -------------------------------------------------------
if [[ $TERM == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
fi

# -------------------------------------------------------
# 'Ctrl + Space' key combination to accept autosuggestions
# -------------------------------------------------------
bindkey '^ ' autosuggest-accept

# -------------------------------------------------------
# Set the zle_highlight style for paste to 'none'
# -------------------------------------------------------
zle_highlight=('paste:none')

# -------------------------------------------------------
# keybinds for zsh-history-substring-search
# -------------------------------------------------------
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# -------------------------------------------------------
# Golang environment variables
# -------------------------------------------------------
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# -------------------------------------------------------
# Update PATH to include GOPATH and GOROOT binaries
# -------------------------------------------------------
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

