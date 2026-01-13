# ~/.zsh/aliases/asdfpy.zsh

asdf.() {
  typeset -A actions=(
    ["🐍 Set Global Python Version"]="asdfpy_set_global"
    ["➕ Install New Python Version"]="asdfpy_install"
    ["🗑️  Uninstall Python Version"]="asdfpy_uninstall"
    ["🧾 Show Installed Versions"]="asdf list python | bat --plain"
    ["👀 Show Active Python Info"]="echo \"Version: \$(python --version)\nPath: \$(which python)\" | bat --plain"
    ["↩️  Revert to System Python"]="asdf global python system && echo '✔️  Reverted to system Python'"
    ["🚪 Quit"]="return"
  )

  local choice=$(printf "%s\n" "${(@k)actions}" | fzf --prompt="🐍  ASDF Python Menu: " --height=40% --border)

  if [[ -n $choice ]]; then
    eval "${actions[$choice]}"
  else
    echo "❌ No action selected."
  fi
}

asdfpy_set_global() {
  local version=$(asdf list python | fzf --prompt="🎯 Select version to activate: " --height=40%)
  [[ -n $version ]] && asdf global python "$version" && echo "✔️  Set Python $version globally"
}

asdfpy_install() {
  local version
  read "version?📦 Enter Python version to install: "
  [[ -n $version ]] && asdf install python "$version" && echo "✔️  Installed Python $version"
}

asdfpy_uninstall() {
  local version=$(asdf list python | fzf --prompt="🗑️  Select version to uninstall: " --height=40%)
  [[ -n $version ]] && asdf uninstall python "$version" && echo "🧹 Uninstalled Python $version"
}

