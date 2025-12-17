#!/bin/bash

# ███ ███ ███ ███   █   █ ███ █   █ ███ ███ ███ ███
# █ █ █   █ █ █ █   ██ ██ █ █ ██  █ █ █ █   █   █ █
# ██  ███ ███ █ █   █ █ █ █ █ █ █ █ █ █ █   ███ ██
# █ █ █   █   █ █   █   █ ███ █  ██ ███ █ █ █   █ █
# █ █ ███ █   ███   █   █ █ █ █   █ █ █ ███ ███ █ █

# -------------------------------------------------------
# Repo Directory
# -------------------------------------------------------
ZSH_PLUGIN_DIR="$HOME/.zsh-plugins"
REPO_DIR="$HOME/Tmp"

# -------------------------------------------------------
# Function to update Git Repos in ~/Repo and ~/.zsh-plugins 
# -------------------------------------------------------
gupdate() {
    # Directories to update
    update_dirs=(
      "$ZSH_PLUGIN_DIR"
      "$REPO_DIR"
    )

    # Arrays to store updated, already up to date, and errored repositories
    updated_repos=()
    up_to_date_repos=()
    errored_repos=()

    for dir in "${update_dirs[@]}"; do
        # Check if the directory exists
        if [ -d "$dir" ]; then
            # Prompt user before updating repositories in the current directory
cat << "EOF"
▖▖▄▖▄ ▄▖▄▖▄▖  ▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖  ▄▖▖ ▖
▌▌▙▌▌▌▌▌▐ ▙▖  ▙▘▙▖▙▌▌▌▚ ▐ ▐ ▌▌▙▘▐ ▙▖▚   ▐ ▛▖▌
▙▌▌ ▙▘▛▌▐ ▙▖  ▌▌▙▖▌ ▙▌▄▌▟▖▐ ▙▌▌▌▟▖▙▖▄▌  ▟▖▌▝▌▗ ▗ ▗
EOF
            echo -n "$dir? (y/n): "
            read choice

            while [[ ! "$choice" =~ ^[yYnN]$ ]]; do
                echo -n "Invalid option. Please enter 'y' for yes or 'n' for no: "
                read choice
            done

            if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
                # Update Git repositories in the current directory
                cd "$dir"
                for d in */; do
                    if [ -d "$d/.git" ]; then
                        # Check for changes before pull
                        before_changes=$(git -C "$d" status --porcelain)

                        (cd "$d" && git pull)

                        # Check for changes after pull
                        after_changes=$(git -C "$d" status --porcelain)

                        if [ "$before_changes" != "$after_changes" ]; then
                            updated_repos+=("$dir/$d")
                        else
                            up_to_date_repos+=("$dir/$d")
                        fi
                    else
                        errored_repos+=("$dir/$d - not a Git repository")
                    fi
                done
            else
                echo "Skipping $dir - user opted not to update repositories"
            fi
        else
            echo "Error: Directory $dir does not exist"
        fi
    done

    # Print the errored repositories
    if [ ${#errored_repos[@]} -gt 0 ]; then
        echo -e "\n==> Errored repositories:"
        for repo in "${errored_repos[@]}"; do
            echo "- $repo"
        done
    fi

    # Print the already up to date repositories
    if [ ${#up_to_date_repos[@]} -gt 0 ]; then
        echo -e "\n==> Already up to date repositories:"
        for repo in "${up_to_date_repos[@]}"; do
            echo "- $repo"
        done
    fi

    # Print the updated repositories
    if [ ${#updated_repos[@]} -gt 0 ]; then
        echo -e "\n==> Updated repositories with local changes:"
        for repo in "${updated_repos[@]}"; do
            echo "- $repo"
        done
    else
        echo "==> No repositories with local changes were updated."
    fi
}


