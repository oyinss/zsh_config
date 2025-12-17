#!/bin/zsh

fpak() {
  # Define the fpurge function for uninstalling apps
  fpurge() {
    # List installed Flatpak apps and select one using fzf
    local app=$(flatpak list --app --columns=application | fzf --prompt="Select Flatpak app to uninstall: ")

    # Uninstall the selected app if any
    if [[ -n "$app" ]]; then
      flatpak uninstall -y "$app"
      echo "$app has been uninstalled."
    else
      echo "No app selected. Exiting."
    fi
  }

  # Define an associative array with Flatpak commands as keys and corresponding commands as values
  declare -A commands=(
    ["List Installed Flatpak Apps"]="flatpak list"
    ["Install a Flatpak App"]="flatpak install"
    ["Uninstall a Flatpak App"]="fpurge"  # Calls your fpurge function
    ["Update all Flatpak Apps"]="flatpak update"
    ["Search for Flatpak Apps"]="flatpak search"
    ["Show Info About a Flatpak App"]="flatpak info"
    ["Add a Remote Flatpak Repo"]="flatpak remote-add"
    ["Remove a Remote Flatpak Repo"]="flatpak remote-delete"
    ["Run a Flatpak App"]="flatpak run"
    ["Quit"]=": # Do nothing"
  )

  # Use fzf to display the Flatpak commands and store the selection
  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 10 --prompt "Select a Flatpak command: " --border)

  # Execute the corresponding command based on the selection
  if [[ -n $choice ]]; then
    if [[ "$choice" == "Uninstall a Flatpak App" ]]; then
      fpurge  # Call fpurge for uninstall
    else
      eval "${commands[$choice]}"
    fi
  else
    echo "Invalid option. Please choose a valid command."
  fi
}
