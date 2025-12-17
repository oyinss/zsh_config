#!/bin/bash

# ███ █   █ █ ███ ███ █   █   █   █ ███ █   █ ███ ███ ███ ███
# █ █ █   █ █ █    █  ██  █   ██ ██ █ █ ██  █ █ █ █   █   █ █
# ███ █   █ █ █    █  █ █ █   █ █ █ █ █ █ █ █ █ █ █   ███ ██
# █   █   █ █ █ █  █  █  ██   █   █ ███ █  ██ ███ █ █ █   █ █
# █   ███ ███ ███ ███ █   █   █   █ █ █ █   █ █ █ ███ ███ █ █

# ------------------------------------------------------
# Function to source plugins in zshrc file
# ------------------------------------------------------
source_plugin() {
    local plugin_name="$1"
    local plugin_path="$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.plugin.zsh"
    local omz_path="$OMZ_PLUGIN_DIR/$plugin_name/$plugin_name.plugin.zsh"
    local plugin_theme="$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.zsh-theme"

    # Check if the plugin file exists
    if [ -f "$plugin_path" ]; then
        source "$plugin_path"
        # echo "Sourced: $plugin_name"
    else
        # echo "Error: Plugin file not found for $plugin_name"
    fi

    # Check if the omz_path is not empty and the plugin file exists
    if [ -n "$omz_path" ] && [ -f "$omz_path" ]; then
        source "$omz_path"
        # echo "Sourced: $plugin_name"
    else
        # echo "Error: Plugin file not found for $plugin_name"
    fi

    # Check if the theme file exists
    if [ -f "$plugin_theme" ]; then
        source "$plugin_theme"
        # echo "Sourced theme: $plugin_name"
    else
        # echo "Error: Theme file not found for $plugin_name"
    fi
}

# Loop to source plugins
for plugin in "${gsource[@]}"; do
    source_plugin "$(basename "$plugin")"
done

# ------------------------------------------------------
# Function to clone plugins using gclone from terminal
# ------------------------------------------------------
gclone() {
  # Prompt user for the repository name
cat << "EOF"
▄▖▖ ▖▄▖▄▖▄▖  ▄▖▄▖▄▖▖▖▖▖▄   ▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▖▖  ▖ ▖▄▖▖  ▖▄▖
▙▖▛▖▌▐ ▙▖▙▘  ▌ ▐ ▐ ▙▌▌▌▙▘  ▙▘▙▖▙▌▌▌▚ ▐ ▐ ▌▌▙▘▌▌  ▛▖▌▌▌▛▖▞▌▙▖
▙▖▌▝▌▐ ▙▖▌▌  ▙▌▟▖▐ ▌▌▙▌▙▘  ▌▌▙▖▌ ▙▌▄▌▟▖▐ ▙▌▌▌▐   ▌▝▌▛▌▌▝ ▌▙▖

EOF
  echo -n "e.g., oyinss/supercharge): "
  read repo_name

  # Trim leading and trailing whitespace from the input
  repo_name=$(echo "$repo_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Check if the input is empty
  if [ -z "$repo_name" ]; then
    echo "Error: Please provide a valid repository name."
    return 1
  fi

  # Create the GitHub repository link
  repo_link="https://github.com/$repo_name.git"

  # Set the destination directory
  destination="$ZSH_PLUGIN_DIR/$(basename "$repo_name")"

  # Check if the repository exists
  if git ls-remote "$repo_link" &>/dev/null; then
    # Clone the repository
    git clone "$repo_link" "$destination"
    # Print a success message
    echo "Repository cloned to $destination"
  else
    echo "Error: The repository '$repo_link' does not exist or is private."
  fi
}

