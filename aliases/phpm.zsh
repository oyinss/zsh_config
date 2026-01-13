#!/bin/zsh

# ===========================
# PHP Command Manager
# ===========================
# Works globally for any user
#
# Optional env vars:
#   PHP_BIN   → default: php
#   PHP_PORT  → default: 8000
#   PHP_HOST  → default: localhost
# ===========================

php.() {
  local PHP_BIN="${PHP_BIN:-php}"
  local PHP_PORT="${PHP_PORT:-8000}"
  local PHP_HOST="${PHP_HOST:-localhost}"

  declare -A commands=(
    ["🐘 PHP Version"]="$PHP_BIN -v"
    ["📦 PHP Modules"]="$PHP_BIN -m"
    ["🧪 PHP Info"]="$PHP_BIN -r 'phpinfo();'"
    ["🌐 Start PHP Dev Server"]="start_php_server"
    ["⛔ Stop PHP Dev Server"]="stop_php_server"
    ["📁 Serve Current Directory"]="serve_here"
    ["📄 Run PHP File"]="run_php_file"
    ["🧹 Syntax Check (Lint)"]="lint_php_file"
    ["🛠 Composer Install"]="composer install"
    ["⬆️ Composer Update"]="composer update"
    ["📦 Composer Dump Autoload"]="composer dump-autoload"
    ["🚪 Quit"]=":"
  )

  # -------- Helper Functions --------

  start_php_server() {
    read "port?Enter port [$PHP_PORT]: "
    port=${port:-$PHP_PORT}
    echo "🚀 Starting PHP server at http://$PHP_HOST:$port (background)"
    $PHP_BIN -S "$PHP_HOST:$port" > /dev/null 2> /dev/null &
    PHP_SERVER_PID=$!
    echo "PHP server started in background with PID $PHP_SERVER_PID. PHP script errors will be logged to the file set in php.ini (error_log)."
    return
  }

  stop_php_server() {
    pkill -f "php -S"
    echo "⛔ PHP server stopped."
  }

  serve_here() {
    read "port?Enter port [$PHP_PORT]: "
    port=${port:-$PHP_PORT}
    echo "📁 Serving $(pwd) at http://$PHP_HOST:$port (background)"
    $PHP_BIN -S "$PHP_HOST:$port" -t . > /dev/null 2> /dev/null &
    PHP_SERVER_PID=$!
    echo "PHP server started in background with PID $PHP_SERVER_PID. PHP script errors will be logged to the file set in php.ini (error_log)."
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

  # -------- Single Menu Selection --------
  local choice
  choice=$(printf "%s\n" "${(@k)commands}" | \
    fzf --height 20 --prompt "🐘 PHP Manager → " --border)

  [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && return
  eval "${commands[$choice]}"
}
