#!/bin/zsh

# █   █ ███ ███ █ █ ███ █   █   ███ █   █ ███ ███ ███ █ █ ███ ███
# ██  █ █   █ █ █ █  █  ██ ██   █   █   █  █   █  █   █ █ █   █ █
# █ █ █ ███ █ █ █ █  █  █ █ █    █  █ █ █  █   █  █   ███ ███ ██
# █  ██ █   █ █ █ █  █  █   █     █ ██ ██  █   █  █   █ █ █   █ █
# █   █ ███ ███  █  ███ █   █   ███ █   █ ███  █  ███ █ █ ███ █ █

#------------------------------------------------------
# Name on folder in .config directory
#------------------------------------------------------
alias lazy="NVIM_APPNAME=nvimLazyVim nvim"
alias kick="NVIM_APPNAME=nvimKickStart nvim"
alias chad="NVIM_APPNAME=nvimChad nvim"
alias astro="NVIM_APPNAME=nvimAstro nvim"

#------------------------------------------------------
# ns function to switch between neovim configuration
#------------------------------------------------------
function ns() {
  items=("default" "nvimKickStart" "nvimLazyVim" "nvimChad" "nvimAstro")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}
# Bind ctrl+y to ns for neovim switcher
bindkey "^Y" ns

