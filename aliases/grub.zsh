#!/bin/zsh

grub() {
  # Define an associative array with emoji-labeled keys
  declare -A commands=(
    ["🔄 Update GRUB"]="sudo grub-mkconfig -o /boot/grub/grub.cfg"
    ["🛠 Grub Configuration"]="sudo nvim /etc/default/grub"
    ["🚪 Quit"]=": # Do nothing"
  )

  # Use fzf to display the emoji-labeled options
  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 10 --prompt "⚙️  Select a GRUB command: " --border)

  # Execute the selected command
  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ Invalid option. Please choose a valid command."
  fi
}

