#!/bin/zsh

# ███ ███ █ █ ███ ███
#   █ █   █ █ █ █ █
#  █   █  ███ ██  █
# █     █ █ █ █ █ █
# ███ ███ █ █ █ █ ███

# -------------------------------------------------------
# Constants
# -------------------------------------------------------
ZSH_CONFIG_DIR="$HOME/.config/zsh"
ENV_FILE="$HOME/.shell.env"
P10K_CONFIG="$HOME/.p10k.zsh"
DIRHISTORY_PLUGIN="$ZSH_CONFIG_DIR/custom_plugins/dirhistory.plugin.zsh"
FIGFONTDIR="$HOME/.config/zsh/figlet-fonts"

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

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# Added by codebase-memory-mcp install
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# kilo
export PATH="$HOME/.kilo/bin:$PATH"

# =======================================================
# ADDITIONS from reference config (setopts, vars, history,
# completion styling, path helpers, utility functions,
# aliases)
# =======================================================

# -------------------------------------------------------
# Additional setopts (not covered by supercharge)
# -------------------------------------------------------
setopt correct             # auto correct mistakes
setopt magicequalsubst     # enable filename expansion for arguments of the form 'anything=expression'
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# -------------------------------------------------------
# Additional Environment Variables
# -------------------------------------------------------
export VISUAL=nvim
export SUDO_EDITOR=nvim
export FCEDIT=nvim

if [[ -x "$(command -v bat)" ]]; then
  export PAGER=bat
fi

if [[ -x "$(command -v fzf)" ]] && [[ -z "${FZF_DEFAULT_OPTS##*--color*}" ]]; then
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --info=inline-right \
    --ansi \
    --layout=reverse \
    --border=rounded \
    --color=border:#27a1b9 \
    --color=fg:#c0caf5 \
    --color=gutter:#16161e \
    --color=header:#ff9e64 \
    --color=hl+:#2ac3de \
    --color=hl:#2ac3de \
    --color=info:#545c7e \
    --color=marker:#ff007c \
    --color=pointer:#ff007c \
    --color=prompt:#2ac3de \
    --color=query:#c0caf5:regular \
    --color=scrollbar:#27a1b9 \
    --color=separator:#ff9e64 \
    --color=spinner:#ff007c \
  "
fi

# -------------------------------------------------------
# History extras
# -------------------------------------------------------
setopt sharehistory        # share history across sessions
setopt histignoredups      # alternative spelling, ensure dedup
HISTDUP=erase              # erase duplicates in history

# -------------------------------------------------------
# Completion styling
# -------------------------------------------------------
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# -------------------------------------------------------
# Path management functions
# -------------------------------------------------------
function pathappend() {
    for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

function pathprepend() {
    for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# -------------------------------------------------------
# Yazi: cd on exit wrapper
# -------------------------------------------------------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# -------------------------------------------------------
# Utility functions
# -------------------------------------------------------

# Start a program detached from terminal
function runfree() {
    "$@" > /dev/null 2>&1 & disown
}

# Copy file with a progress bar (rsync preferred, strace fallback)
function cpp() {
    if [[ -x "$(command -v rsync)" ]]; then
        rsync -ah --info=progress2 "${1}" "${2}"
    else
        set -e
        strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
        | awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
                printf ">"
                for (i=percent;i<100;i++)
                    printf " "
                    printf "]\r"
                }
            }
        END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
    fi
}

# Copy and go to directory
function cpg() {
    if [[ -d "$2" ]]; then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# Move and go to directory
function mvg() {
    if [[ -d "$2" ]]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Create directory and go into it
function mkdirg() {
    mkdir -p "$@" && cd "$@"
}

# Print random Unicode bar chart across terminal width
function random_bars() {
    columns=$(tput cols)
    chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
    for ((i = 1; i <= $columns; i++)); do
        echo -n "${chars[RANDOM%${#chars} + 1]}"
    done
    echo
}
