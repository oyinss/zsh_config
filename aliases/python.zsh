#!/bin/zsh

# ███ █ █ ███ █ █ ███ █   █   ███ █   ███ ███ ███ ███ ███
# █ █ █ █  █  █ █ █ █ ██  █   █ █ █    █  █ █ █   █   █
# ███  █   █  ███ █ █ █ █ █   █ █ █    █  █ █  █  ███  █
# █    █   █  █ █ █ █ █  ██   ███ █    █  ███   █ █     █
# █    █   █  █ █ ███ █   █   █ █ ███ ███ █ █ ███ ███ ███

# -------------------------------------------
# Activate or create environment variable for python in current directory if not available
# -------------------------------------------
myenv() {
    venv_name="myenv"

    if [ -d "$venv_name" ]; then
        source "$venv_name/bin/activate"
    else
        python -m venv "$venv_name"
        source "$venv_name/bin/activate"
    fi
}

p3() {
  # Define an associative array with Python-related commands as keys and corresponding commands as values
  declare -A commands=(
    ["Run Python App"]="python app.py"
    ["Run Python Test"]="python test.py"
    ["Run Flask App on Port 8000"]="flask run --port=8000"
    ["Python Version"]="python --version"
    ["Pip3 List"]="pip3 list"
    ["Pip3 Install"]="pip3 install"
    ["Pip3 Uninstall"]="pip3 install"
    # ["Deactivate myenv"]="deactivate"
    ["Upgrade Packages (Pip3)"]="pip3 install --upgrade"
    ["Switch Python Version"]="sudo update-alternatives --config python3"
    ["Quit"]=": # Do nothing"
  )

  # Use fzf to display the options and store the selection
  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 10 --prompt "Select a Python command: " --border)

  # Execute the corresponding command based on the selection
  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "Invalid option. Please choose a valid command."
  fi
}

# # Run python
py() {
    local file
    file=$( (echo "main.py"; find . -type f -name "*.py" ! -path "./myenv/*" ! -path "./__pycache__/*" ! -name "main.py" | sed 's|^\./||') | fzf --preview "bat --style=numbers --color=always --line-range :500 {}" --height 40% --border --ansi)
    if [[ -n "$file" ]]; then
        python "$file"
    else
        echo "No file selected"
    fi
}

