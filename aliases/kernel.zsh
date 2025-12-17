#!/bin/zsh

kernel() {
  # Define an associative array with emoji-labeled keys
  declare -A commands=(
    ["🔍 Check current kernel version"]="uname -r"
    ["🧬 Check detailed kernel version"]="uname -a"
    ["📦 List all installed kernels"]="pacman -Q | grep linux"
    ["🧹 Remove old kernels"]="sudo pacman -Rns $(pacman -Qdtq)"
    ["🔧 Update initramfs"]="sudo mkinitcpio -P"
    ["⚙️  Update GRUB"]="sudo grub-mkconfig -o /boot/grub/grub.cfg"
    ["🔄 Update grub and initramfs"]="sudo grub-mkconfig -o /boot/grub/grub.cfg && sudo mkinitcpio -P"
    ["⬆️ Install latest kernel"]="sudo pacman -Syu linux"
    ["⚡️ Install Zen kernel"]="sudo pacman -S linux-zen linux-zen-headers"
    ["🛡 Install LTS kernel"]="sudo pacman -S linux-lts linux-lts-headers"
    ["📝 Check kernel logs (dmesg)"]="dmesg | less"
    ["🚪 Quit"]=": # Do nothing"
  )

  # fzf selection menu
  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 15 --prompt "🧠 Select a kernel command: " --border)

  # Execute the selected command
  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ Invalid option. Please choose a valid command."
  fi
}

