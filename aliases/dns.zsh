#!/bin/zsh

dns() {
  # Define an associative array with NextDNS commands
  declare -A commands=(
    ["Install/Upgrade/Uninstall NextDNS"]="sh -c '$(curl -sL https://nextdns.io/install)'"
    ["Start NextDNS"]="nextdns start"
    ["Stop NextDNS"]="nextdns stop"
    ["Restart NextDNS"]="nextdns restart"
    ["Activate NextDNS"]="sudo nextdns activate"
    ["Deactivate NextDNS"]="sudo nextdns deactivate"
    ["Show NextDNS Logs"]="nextdns log"
    ["Help and More Commands"]="nextdns help"
    ["Quit"]=": # Quit the function"
  )

  while true; do
    # Use fzf to display the commands and store the selection
    local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 10 --prompt "Select a NextDNS command (or Quit): " --border)

    # If no command is selected or 'Quit' is chosen, exit the loop
    if [[ -z "$choice" || "$choice" == "Quit" ]]; then
      echo "Exiting NextDNS manager."
      break
    fi

    # Execute the selected command
    eval "${commands[$choice]}"
  done
}

