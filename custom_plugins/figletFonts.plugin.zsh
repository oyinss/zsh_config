#!/bin/zsh

# ███ ███ ███ █   ███ ███   ███ ███ █   █ ███
# █    █  █   █   █    █    █   █ █ ██  █  █
# ███  █  █   █   ███  █    ███ █ █ █ █ █  █
# █    █  █ █ █   █    █    █   █ █ █  ██  █
# █   ███ ███ ███ ███  █    █   ███ █   █  █

#------------------------------------------------------
# usage: font "Text Example" OR font "Text Example" 3d
#------------------------------------------------------
font() {
    # Check if the correct number of arguments is provided
    if [ "$#" -lt 1 ]; then
        echo "Usage: font <text> [font]"
        return 1
    fi

    # Assign the text and font to variables
    text=$(echo "$1" | tr '[:lower:]' '[:upper:]')  # Convert text to uppercase
    selected_font="${2}"

    # Build the figlet commands
    maxiwi_cmd="figlet -t -f maxiwi \"$text\" | lolcat"
    miniwi_cmd="figlet -t -f miniwi \"$text\" | lolcat"

    # Execute the specified font command if provided, otherwise execute both
    if [ -n "$selected_font" ]; then
        eval "figlet -t -f $selected_font \"$text\" | lolcat"
    else
        echo 'cat << "EOF"'
        eval "$maxiwi_cmd"
        echo "EOF"
        echo 'cat << "EOF"'
        eval "$miniwi_cmd"
        echo "EOF"
    fi
}

