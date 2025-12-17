#!/bin/zsh

# █   █ ███ ███ ███ ███ ███   ███ █   ███ ███ ███ ███ ███
# ██ ██  █  █ █ █ █ █ █ █ █   █ █ █    █  █ █ █   █   █
# █ █ █  █  ██  ██  █ █ ██    █ █ █    █  █ █  █  ███  █
# █   █  █  █ █ █ █ █ █ █ █   ███ █    █  ███   █ █     █
# █   █ ███ █ █ █ █ ███ █ █   █ █ ███ ███ █ █ ███ ███ ███

mirror() {
  # Define an associative array with emoji-labeled mirror commands
  declare -A commands=(
    ["🌐 Reflector Update Fastest Mirror Worldwide"]="sudo reflector --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
    ["🌍 Reflector Update 30 Fastest Mirror Worldwide"]="sudo reflector --protocol https --sort rate --number 30 --save /etc/pacman.d/mirrorlist"
    ["⚡️ Rate Update Manjaro Mirrors"]="rate-mirrors --allow-root --protocol https manjaro | sudo tee /etc/pacman.d/mirrorlist"
    ["🚀 Rate Update EndeavourOS Mirrors"]="rate-mirrors --allow-root --protocol https endeavouros | sudo tee /etc/pacman.d/endeavouros-mirrorlist"
    ["📈 Rank Current Mirrors"]="rankmirrors /etc/pacman.d/mirrorlist"
    ["📜 EndeavourOS Mirror List"]="sudo nvim /etc/pacman.d/endeavouros-mirrorlist"
    ["📜 Arch Mirror List"]="sudo nvim /etc/pacman.d/mirrorlist"
    ["📜 Chaotic Mirror List"]="sudo nvim /etc/pacman.d/chaotic-mirrorlist"
    ["🛠 Configure pacman.conf"]="sudo nvim /etc/pacman.conf"
    ["🚪 Quit"]=": # Do nothing"
  )

  # fzf menu selection
  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 15 --prompt "🔗 Select a mirror command: " --border)

  # Execute the selected command
  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ Invalid option. Please choose a valid command."
  fi
}

