#!/bin/zsh

# ███ ███ █ █ ███ ███
#   █ █   █ █ █ █ █
#  █   █  ███ ██  █
# █     █ █ █ █ █ █
# ███ ███ █ █ █ █ ███

# -------------------------------------------------------
# Constants
# -------------------------------------------------------
ZSH_CONFIG_DIR="$HOME/zsh"
ENV_FILE="$HOME/.env"
P10K_CONFIG="$HOME/.p10k.zsh"
DIRHISTORY_PLUGIN="$ZSH_CONFIG_DIR/custom_plugins/dirhistory.plugin.zsh"
FIGFONTDIR="$HOME/zsh/figlet-fonts"

# -------------------------------------------------------
# Display username banner
# -------------------------------------------------------
if [[ -f "$FIGFONTDIR/dosrebel.flf" ]]; then
  figlet -d "$FIGFONTDIR" -f dosrebel "$(echo $USER | tr '[:lower:]' '[:upper:]' | head -c 1)${USER:1}" | lolcat
else
  echo "$USER" | lolcat
fi

# -------------------------------------------------------
# Source environment file if it exists
# -------------------------------------------------------
if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

# -------------------------------------------------------
# Install & source Zap
# -------------------------------------------------------
if [[ ! -f "$HOME/.local/share/zap/zap.zsh" ]]; then
  mkdir -p "$HOME/.local/share/zap"
  git clone https://github.com/zap-zsh/zap.git "$HOME/.local/share/zap" >/dev/null 2>&1
fi
[[ -f "$HOME/.local/share/zap/zap.zsh" ]] && source "$HOME/.local/share/zap/zap.zsh"

# -------------------------------------------------------
# Plugins
# -------------------------------------------------------
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
plug "zap-zsh/supercharge"
plug "oyinss/ginit"
plug "zap-zsh/vim"
plug "zap-zsh/fzf"
plug "zap-zsh/sudo"
plug "djui/alias-tips"
plug "esc/conda-zsh-completion"
plug "hlissner/zsh-autopair"
plug "romkatv/powerlevel10k"

# -------------------------------------------------------
# Load dirhistory without OMZ
# -------------------------------------------------------
if [[ ! -f "$DIRHISTORY_PLUGIN" ]]; then
  mkdir -p "$ZSH_CONFIG_DIR/custom_plugins"
  curl -sL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/dirhistory/dirhistory.plugin.zsh \
    -o "$DIRHISTORY_PLUGIN"
fi
[[ -f "$DIRHISTORY_PLUGIN" ]] && source "$DIRHISTORY_PLUGIN"

# -------------------------------------------------------
# History format
# -------------------------------------------------------
export HISTTIMEFORMAT="%F %T "

# -------------------------------------------------------
# Powerlevel10k instant prompt
# -------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------------------------------------
# Load custom aliases and functions
# -------------------------------------------------------
if [[ -d "$ZSH_CONFIG_DIR/custom_plugins" ]]; then
  for file in "$ZSH_CONFIG_DIR/custom_plugins/"*.zsh(N); do source "$file"; done
fi

if [[ -d "$ZSH_CONFIG_DIR/aliases" ]]; then
  for file in "$ZSH_CONFIG_DIR/aliases/"*.zsh(N); do source "$file"; done
fi

# -------------------------------------------------------
# Powerlevel10k config
# -------------------------------------------------------
[[ -f "$P10K_CONFIG" ]] && source "$P10K_CONFIG"

# -------------------------------------------------------
# Environment & completions
# -------------------------------------------------------
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export PYTHON_CONFIGURE_OPTS="--with-openssl=/usr"
export LDFLAGS="-L/usr/library"
export CPPFLAGS="-I/usr/include"

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  . "$HOME/.asdf/asdf.sh"
  fpath=("$HOME/.asdf/completions" $fpath)
fi

autoload -Uz compinit && compinit

export EDITOR=nvim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/flutter/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH="$JAVA_HOME/bin:$PATH"
export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
