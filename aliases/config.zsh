#!/bin/zsh

conf() {
  # Define an associative array with emoji-labeled configuration file commands
  declare -A configs=(
    ["⚙️  Edit Auto-CPUFreq Config"]="nvim ~/dotfiles/etc/auto-cpufreq.conf"
    ["🖥 Edit Alacritty Config"]="nvim ~/.config/alacritty/alacritty.yml"
    ["🐱 Edit Kitty Config"]="nvim ~/.config/kitty/kitty.conf"
    ["🧩 Edit GRUB Config"]="sudo nvim /etc/default/grub"
    ["🔧 Edit mkinitcpio Config"]="sudo nvim /etc/mkinitcpio.conf"
    ["📦 Edit Pacman Config"]="sudo nvim /etc/pacman.conf"
    ["💻 Edit Zsh Config"]="nvim ~/.zshrc"
    ["🎬 Edit Xinit Config"]="nvim ~/.xinitrc"
    ["📜 Edit Bash Config"]="nvim ~/.bashrc"
    ["🌍 Edit Environment Variables"]="sudo nvim /etc/environment"
    ["🏠 Edit Hosts File"]="sudo nvim /etc/hosts"
    ["🌐 Edit AdGuard DNS Config"]="sudo nvim /etc/systemd/resolved.conf"
    ["💾 Edit FSTAB"]="sudo nvim /etc/fstab"
    ["🚪 Quit"]=": # Do nothing"
  )

  # fzf selection menu
  local choice=$(printf "%s\n" "${(@k)configs}" | fzf --height 15 --prompt "🗂 Select a configuration file: " --border)

  # Execute the selected command
  if [[ -n $choice ]]; then
    eval "${configs[$choice]}"
  else
    echo "❌ Invalid option. Please choose a valid command."
  fi
}

