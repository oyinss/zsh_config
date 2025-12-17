#!/bin/zsh

# Editor Configurations
alias vide="neovide"
alias vs="sudo nvim"
alias v="nvim"

o() {
    # Use find to list files in the current directory, excluding __pycache__, myenv, and .git directories
    local file=$(find . -type f -not -path './__pycache__/*' -not -path './myenv/*' -not -path './.git/*' -printf "%P\n" | fzf --preview "cat {}" --height 40%)

    # If a file is selected, open it with nvim
    if [ -n "$file" ]; then
        nvim "$file"
    else
        # If no file is selected, ask the user for a new filename
        read -p "Enter a new filename: " newfile

        # If the file doesn't exist, create and open it with nvim
        if [ ! -z "$newfile" ]; then
            nvim "$newfile"
        fi
    fi
}

