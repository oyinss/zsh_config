#!/bin/zsh

dir() {
  # Define an associative array with emoji-labeled directory cd commands
  declare -A directories=(
    ["🗂 Config"]="cd ~/.config"
    ["📝 Neovim Config"]="cd ~/.config/nvim"
    ["📁 Dotfiles"]="cd ~/dotfiles"
    ["🧩 Hub"]="cd ~/Hub"
    ["🐱 Kitty Config"]="cd ~/.config/kitty/"
    ["📦 Pacman Cache (PKG)"]="cd /var/cache/pacman/pkg"
    ["🎨 Alacritty Config"]="cd ~/.config/alacritty/"
    ["🖼 Pictures"]="cd ~/Pictures"
    ["📜 Aliases"]="cd ~/dotfiles/zsh/aliases"
    ["💻 Zsh"]="cd ~/dotfiles/zsh"
  )

  # Use fzf to display the directory options
  local choice=$(printf "%s\n" "${(@k)directories}" | fzf --height 15 --prompt "📂 Select a directory: " --border)

  # Execute the selected cd command
  if [[ -n $choice ]]; then
    eval "${directories[$choice]}"
  else
    echo "❌ Invalid option. Please choose a valid directory."
  fi
}

