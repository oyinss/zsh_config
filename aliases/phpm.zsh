#!/bin/zsh

# ===========================
# PHP Command Manager
# ===========================
# Works globally for any user
#
# Optional env vars:
#   PHP_BIN   → default: php
#   PHP_PORT  → default: 9000
#   PHP_HOST  → default: localhost
# ===========================

phpm() {
  local PHP_BIN="${PHP_BIN:-php}"
  local PHP_PORT="${PHP_PORT:-9000}"
  local PHP_HOST="${PHP_HOST:-localhost}"

  declare -A commands=(
    ["🐘 PHP Version"]="$PHP_BIN -v"
    ["📦 PHP Modules"]="$PHP_BIN -m"
    ["🧪 PHP Info"]="$PHP_BIN -r 'phpinfo();'"    ["🔀 Switch PHP Version"]="switch_php_version"    ["🌐 Start PHP Dev Server"]="start_php_server"
    ["⛔ Stop PHP Dev Server"]="stop_php_server"
    ["📁 Serve Current Directory"]="serve_here"
    ["📄 Run PHP File"]="run_php_file"
    ["🧹 Syntax Check (Lint)"]="lint_php_file"
    ["🛠 Composer Install"]="composer install"
    ["⬆️ Composer Update"]="composer update"
    ["📦 Composer Dump Autoload"]="composer dump-autoload"
    
    ["�🚪 Quit"]=":"
  )

  # -------- Helper Functions --------

  start_php_server() {
    read "port?Enter port [$PHP_PORT]: "
    port=${port:-$PHP_PORT}
    echo "🚀 Starting PHP server at http://$PHP_HOST:$port (background)"
    local LOG="${PHP_ERROR_LOG:-$PWD/php_errors.log}"
    mkdir -p "$(dirname "$LOG")" >/dev/null 2>&1
    touch "$LOG" >/dev/null 2>&1
    $PHP_BIN -d error_log="$LOG" -S "$PHP_HOST:$port" > /dev/null 2> /dev/null &
    PHP_SERVER_PID=$!
    echo "PHP server started in background with PID $PHP_SERVER_PID. PHP script errors will be logged to $LOG."
    return
  }

  stop_php_server() {
    local count=$(pgrep -f "php.*-S" | wc -l)
    if [[ $count -eq 0 ]]; then
      echo "⚠️  No PHP server found running."
      return 1
    fi
    pkill -9 -f "php.*-S"
    echo "⛔ PHP server stopped ($count process(es) killed)."
  }

  serve_here() {
    read "port?Enter port [$PHP_PORT]: "
    port=${port:-$PHP_PORT}
    echo "📁 Serving $(pwd) at http://$PHP_HOST:$port (background)"
    local LOG="${PHP_ERROR_LOG:-$PWD/php_errors.log}"
    mkdir -p "$(dirname "$LOG")" >/dev/null 2>&1
    touch "$LOG" >/dev/null 2>&1
    $PHP_BIN -d error_log="$LOG" -S "$PHP_HOST:$port" -t . > /dev/null 2> /dev/null &
    PHP_SERVER_PID=$!
    echo "PHP server started in background with PID $PHP_SERVER_PID. PHP script errors will be logged to $LOG."
    return
  }

  run_php_file() {
    read "file?Enter PHP file path: "
    $PHP_BIN "$file"
  }

  lint_php_file() {
    read "file?Enter PHP file to lint: "
    $PHP_BIN -l "$file"
  }

  switch_php_version() {
    # Suppress debug output from xtrace
    local _restore_xtrace=false
    [[ $- == *x* ]] && _restore_xtrace=true
    set +x

    local available_versions=()

    # Search for PHP binaries in common locations using zsh nullglob (N)
    local search_dirs=(/usr/bin /usr/local/bin /opt/php /snap/bin)

    for dir in "${search_dirs[@]}"; do
      [[ ! -d "$dir" ]] && continue

      # Match names like php, php7.4, php8.1, php83, php8.3, etc.
      for php_file in "$dir"/php*(N) "$dir"/php[0-9]*(*N); do
        [[ -z "$php_file" ]] && continue
        [[ -x "$php_file" ]] || continue

        # Only include actual PHP CLI binaries: ensure `-v` outputs a line starting with "PHP"
        if "$php_file" -v 2>/dev/null | grep -q '^PHP'; then
          if [[ ! " ${available_versions[*]} " == *" $php_file "* ]]; then
            available_versions+=("$php_file")
          fi
        fi
      done
    done

    # Sort and remove duplicates
    available_versions=(${(o)available_versions[@]})

    if [[ ${#available_versions[@]} -eq 0 ]]; then
      echo "❌ No PHP versions found. Please check your PHP installation."
      [[ "$_restore_xtrace" == true ]] && set -x
      return 1
    fi

    if [[ ${#available_versions[@]} -eq 1 ]]; then
      echo "ℹ️  Only one PHP version found: ${available_versions[1]}"
      echo "Version: $("${available_versions[1]}" -v | head -1)"
      [[ "$_restore_xtrace" == true ]] && set -x
      return
    fi

    # Temporarily disable xtrace if enabled to avoid debug prints
    local _xset_state
    _xset_state=$-
    case "$_xset_state" in *x*) set +x;; esac

    # Show list with compact labels: store full path, display basename + version
    local selected
    selected=$(for php_path in "${available_versions[@]}"; do
        version=$("$php_path" -v 2>/dev/null | head -1)
        printf '%s\t%s (%s)\n' "$php_path" "$(basename "$php_path")" "$version"
      done | fzf --height 10 --prompt "🔀 Select PHP version → " --border)

    # Restore xtrace state
    case "$_xset_state" in *x*) set -x;; esac

    if [[ -z "$selected" ]]; then
      echo "❌ No PHP version selected."
      [[ "$_restore_xtrace" == true ]] && set -x
      return 1
    fi

    # Extract full path (before tab)
    local selected_php="${selected%%$'\t'*}"

    if [[ ! -x "$selected_php" ]]; then
      echo "❌ Selected PHP path is not executable: $selected_php"
      [[ "$_restore_xtrace" == true ]] && set -x
      return 1
    fi

    export PHP_BIN="$selected_php"
    
    # Create a shell function that overrides 'php' to use the selected version
    eval "php() { $selected_php \"\$@\"; }"
    
    echo "✅ PHP version switched to: $selected_php"
    echo "Current version: $("$selected_php" -v | head -1)"
    
    # Restore xtrace if it was enabled on entry
    [[ "$_restore_xtrace" == true ]] && set -x
  }


  # -------- Single Menu Selection --------
  local choice
  choice=$(printf "%s\n" "${(@k)commands}" | \
    fzf --height 20 --prompt "🐘 PHP Manager → " --border)

  [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && return
  eval "${commands[$choice]}"
}

# ===========================
# Convenient Aliases
# ===========================
alias stop='pkill -9 -f "php.*-S" && echo "⛔ PHP server stopped." || echo "⚠️  No PHP server running."'
alias phpstop='pkill -9 -f "php.*-S" && echo "⛔ PHP server stopped." || echo "⚠️  No PHP server running."'
alias phpstart='php -S localhost:9000'
alias phpserve='php -S localhost:9000 -t .'
