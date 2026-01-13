#!/bin/zsh

espanso.() {
  typeset -A commands=(
    ["📶 Check Espanso Status"]="espanso status"
    ["🚀 Start Espanso"]="espanso start"
    ["🛑 Stop Espanso"]="espanso stop"
    ["🔄 Restart Espanso"]="espanso restart"
    ["💀 Kill Espanso"]="pkill -9 espanso"
    ["📜 View Logs"]="espanso log"
    ["⚙️ Edit Config (nvim)"]="nvim ~/.config/espanso/config/default.yml"
    ["🧩 Edit Matches"]="edit_match"
    ["📦 Edit Packages"]="nvim ~/.config/espanso/match/packages"
    ["🔧 Doctor (Debug)"]="espanso doctor"
    ["🔁 Reload Config"]="espanso restart"
    ["➕ Add New Trigger"]="add"
    ["🚪 Quit"]="return"
  )

  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height=14 --prompt="🧠  Espanso Menu: " --border)

  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ No option selected."
  fi
}

add() {
  local match_dir="$HOME/.config/espanso/match"
  local target=$(find "$match_dir" -type f -name '*.yml' | fzf --prompt="📄 Select target YAML: " --height=10)
  local tmpfile=$(mktemp)

  if [[ -z "$target" ]]; then
    echo "❌ No file selected."
    return 1
  fi

  echo "📄 Selected file: $target"
  echo "🧠 You can add multiple triggers. Press ENTER on an empty trigger to finish."
  echo

  while true; do
    echo -n "🧵 Enter Trigger (e.g ;sea) or ENTER to Exit: "
    read trigger
    [[ -z "$trigger" ]] && break

    echo -n "💬 Enter Replacment: "
    read replace

    if [[ -z "$replace" ]]; then
      echo "❌ Replace text cannot be empty."
      continue
    fi

    # echo >> "$tmpfile"
    echo "  - trigger: \"$trigger\"" >> "$tmpfile"
    echo "    replace: \"$replace\"" >> "$tmpfile"
    echo "✅ Buffered trigger \"$trigger\""
  done

  if [[ -s "$tmpfile" ]]; then
    echo >> "$target"
    cat "$tmpfile" >> "$target"
    echo "📦 All triggers appended to $target"
    echo "🔁 Run 'espanso restart' manually when ready."
  else
    echo "⚠️ No triggers were added."
  fi

  rm -f "$tmpfile"
}

edit_match() {
  local match_dir="$HOME/.config/espanso/match"
  local target=$(find "$match_dir" -type f -name '*.yml' | fzf --prompt="📝 Select YAML to edit: " --height=10)

  if [[ -z "$target" ]]; then
    echo "❌ No file selected."
    return 1
  fi

  nvim "$target"
}

