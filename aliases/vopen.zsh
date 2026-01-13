vo() {
  local dir="$PWD"   # Use current directory
  local choices
  local selection

  # List all files in the current directory + Quit
  choices=$(printf "%s\n" "$dir"/* "🚪 Quit")

  # FZF menu
  selection=$(echo "$choices" | fzf --height 20 --prompt "Select file to open: " --border)

  # No selection (Esc)
  [[ -z "$selection" ]] && return

  # Quit option
  if [[ "$selection" == "🚪 Quit" ]]; then
    return
  fi

  # Open file in existing VS Code window
  code-insiders -r "$selection"
}
