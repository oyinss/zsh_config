# ----------------------------
# QUICK COMMANDS (TOP LEVEL)
# ----------------------------

# Install a package (quick)
alias deploy="paru -S"

# Remove a package (quick)
alias purge="paru -R"


# ----------------------------
# INTERACTIVE UPDATE MENU
# ----------------------------

arch() {
  local choice

  choice=$(printf "%s\n" \
    "🌀 Update databases only (paru -Sy)" \
    "⬆️  Full system upgrade (paru -Syu)" \
    "📦 Install / upgrade a package" \
    "🧹 Remove package + unneeded deps (paru -Rs)" \
    "🔥 Remove package + all deps (paru -Rns)" \
    "📂 Install local package file (paru -U)" \
    "🔍 Search packages (paru -Ss)" \
    "📋 Query installed packages (paru -Qs)" \
    "🧠 Check if package is installed" \
    "🧩 Find package providing a file (paru -F)" \
    "🪦 Remove orphan packages" \
    "⏪ Downgrade packages (paru -Suu)" \
    "🧼 Clean package cache (paru -Sc)" \
    "🧨 Clean ALL cache (paru -Scc)" \
    "🔓 Unlock pacman database" \
    "🚪 Quit" \
    | fzf --height 18 --prompt "Select package action: " --border)

  case "$choice" in
    "🌀 Update databases only (paru -Sy)")
      paru -Sy
      ;;
    "⬆️  Full system upgrade (paru -Syu)")
      paru -Syu
      ;;
    "📦 Install / upgrade a package")
      read "?Enter package name: " pkg
      [[ -n "$pkg" ]] && paru -S "$pkg"
      ;;
    "🧹 Remove package + unneeded deps (paru -Rs)")
      read "?Enter package name: " pkg
      [[ -n "$pkg" ]] && paru -Rs "$pkg"
      ;;
    "🔥 Remove package + all deps (paru -Rns)")
      read "?Enter package name: " pkg
      [[ -n "$pkg" ]] && paru -Rns "$pkg"
      ;;
    "📂 Install local package file (paru -U)")
      read "?Enter path to package file: " file
      [[ -n "$file" ]] && paru -U "$file"
      ;;
    "🔍 Search packages (paru -Ss)")
      read "?Search term: " term
      [[ -n "$term" ]] && paru -Ss "$term"
      ;;
    "📋 Query installed packages (paru -Qs)")
      read "?Query term: " term
      [[ -n "$term" ]] && paru -Qs "$term"
      ;;
    "🧠 Check if package is installed")
      read "?Package name: " term
      [[ -n "$term" ]] && paru -Q | grep "$term"
      ;;
    "🧩 Find package providing a file (paru -F)")
      read "?File name or path: " term
      [[ -n "$term" ]] && paru -F "$term"
      ;;
    "🪦 Remove orphan packages")
      orphans=$(paru -Qtdq)
      [[ -n "$orphans" ]] && paru -R $orphans || echo "No orphan packages found"
      ;;
    "⏪ Downgrade packages (paru -Suu)")
      paru -Suu
      ;;
    "🧼 Clean package cache (paru -Sc)")
      paru -Sc
      ;;
    "🧨 Clean ALL cache (paru -Scc)")
      paru -Scc
      ;;
    "🔓 Unlock pacman database")
      sudo rm -rf /var/lib/pacman/db.lck
      ;;
    *)
      return
      ;;
  esac
}

