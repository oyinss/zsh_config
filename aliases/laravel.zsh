#!/bin/zsh

# ===========================
# Laravel Command Manager
# Provides a `laravel` interactive menu (fzf) that runs `artisan`
# Defaults: PHP_BIN=php83, LARAVEL_PORT=8000, LARAVEL_HOST=127.0.0.1
# Usage: source this file then run `laravel` to pick actions
# ===========================

export PHP_BIN="${PHP_BIN:-php83}"
export LARAVEL_PORT="${LARAVEL_PORT:-8000}"
export LARAVEL_HOST="${LARAVEL_HOST:-127.0.0.1}"

lrv() {
  local PHP_BIN="${PHP_BIN:-php83}"
  local LARAVEL_PORT="${LARAVEL_PORT:-8000}"
  local LARAVEL_HOST="${LARAVEL_HOST:-127.0.0.1}"
  local reset=$'\033[0m'
  local blue=$'\033[38;5;75m'
  local cyan=$'\033[38;5;80m'
  local green=$'\033[38;5;114m'
  local yellow=$'\033[38;5;221m'
  local purple=$'\033[38;5;141m'
  local red=$'\033[38;5;203m'
  local orange=$'\033[38;5;208m'

  local serve_label=" Serve (background)"
  local stop_label="󰓛 Stop Serve"
  local php_label=" PHP Version"
  local composer_install_label="󰏖 Composer Install"
  local composer_update_label="󰚰 Composer Update"
  local dump_autoload_label="󰆍 Dump Autoload"
  local migrate_label="󰆼 Migrate"
  local migrate_fresh_label="󰜉 Migrate Fresh"
  local migrate_rollback_label="󰑕 Migrate Rollback"
  local migrate_status_label="󰄬 Migrate Status"
  local seed_label="󰹰 DB Seed"
  local seed_permissions_label="󰌾 Seed Permissions"
  local deploy_label="󰒋 Deploy"
  local clear_cache_label="󰃢 Clear Cache"
  local clear_all_label="󰃢 Clear View & Cache"
  local config_cache_label="󰒓 Config Cache"
  local route_cache_label="󰑪 Route Cache"
  local view_clear_label="󰈙 View Clear"
  local storage_link_label="󰌷 Storage Link"
  local key_generate_label="󰌋 Key Generate"
  local test_label="󰙨 Run Tests"
  local tinker_label="󰘦 Tinker"
  local make_controller_label="󰡱 Make:Controller"
  local make_model_label="󰆼 Make:Model"
  local make_migration_label="󰆼 Make:Migration"
  local make_middleware_label="󰹥 Make:Middleware"
  local queue_label="󰜎 Queue Work"
  local quit_label="󰅙 Quit"

  declare -A commands=(
    ["$php_label"]="$PHP_BIN -v"
    ["$composer_install_label"]="composer install"
    ["$composer_update_label"]="composer update"
    ["$dump_autoload_label"]="composer dump-autoload"

    ["$migrate_label"]="artisan_migrate"
    ["$migrate_fresh_label"]="artisan_migrate_fresh"
    ["$migrate_rollback_label"]="artisan_migrate_rollback"
    ["$migrate_status_label"]="artisan_migrate_status"
    ["$seed_label"]="artisan_db_seed"
    ["$seed_permissions_label"]="artisan_db_seed_permissions"
    ["$deploy_label"]="artisan_deploy"
    ["$clear_cache_label"]="artisan_cache_clear"
    ["$clear_all_label"]="artisan_clear_all"
    ["$config_cache_label"]="artisan_config_cache"
    ["$route_cache_label"]="artisan_route_cache"
    ["$view_clear_label"]="artisan_view_clear"
    ["$storage_link_label"]="artisan_storage_link"
    ["$key_generate_label"]="artisan_key_generate"
    ["$test_label"]="artisan_test"
    ["$tinker_label"]="artisan_tinker"

    ["$stop_label"]="stop_artisan_server"
    ["$serve_label"]="start_artisan_server"

    ["$make_controller_label"]="make_controller"
    ["$make_model_label"]="make_model"
    ["$make_migration_label"]="make_migration"
    ["$make_middleware_label"]="make_middleware"

    ["$queue_label"]="artisan_queue_work"
    ["$quit_label"]=":"
  )

  # Ordered menu so Serve can be the default selection with reverse layout
  local -a menu=(
    "${green}${reset} ${purple}Serve (background)${reset}"
    "${blue}${reset} ${purple}PHP Version${reset}"
    "${green}󰏖${reset} ${purple}Composer Install${reset}"
    "${green}󰚰${reset} ${purple}Composer Update${reset}"
    "${cyan}󰆍${reset} ${purple}Dump Autoload${reset}"
    "${yellow}󰆼${reset} ${purple}Migrate${reset}"
    "${orange}󰜉${reset} ${purple}Migrate Fresh${reset}"
    "${yellow}󰑕${reset} ${purple}Migrate Rollback${reset}"
    "${cyan}󰄬${reset} ${purple}Migrate Status${reset}"
    "${green}󰹰${reset} ${purple}DB Seed${reset}"
    "${orange}󰌾${reset} ${purple}Seed Permissions${reset}"
    "${green}󰒋${reset} ${purple}Deploy${reset}"
    "${yellow}󰃢${reset} ${purple}Clear Cache${reset}"
    "${yellow}󰃢${reset} ${purple}Clear View & Cache${reset}"
    "${cyan}󰒓${reset} ${purple}Config Cache${reset}"
    "${cyan}󰑪${reset} ${purple}Route Cache${reset}"
    "${blue}󰈙${reset} ${purple}View Clear${reset}"
    "${cyan}󰌷${reset} ${purple}Storage Link${reset}"
    "${yellow}󰌋${reset} ${purple}Key Generate${reset}"
    "${green}󰙨${reset} ${purple}Run Tests${reset}"
    "${blue}󰘦${reset} ${purple}Tinker${reset}"
    "${red}󰅙${reset} ${purple}Quit${reset}"
    "${red}󰓛${reset} ${purple}Stop Serve${reset}"
    "${cyan}󰡱${reset} ${purple}Make:Controller${reset}"
    "${yellow}󰆼${reset} ${purple}Make:Model${reset}"
    "${yellow}󰆼${reset} ${purple}Make:Migration${reset}"
    "${orange}󰹥${reset} ${purple}Make:Middleware${reset}"
    "${blue}󰜎${reset} ${purple}Queue Work${reset}"
  )

  # Helper wrappers
  artisan_exec() {
    local PHP_BIN="${PHP_BIN:-php83}"
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
      if [[ -f "$dir/artisan" ]]; then
        "$PHP_BIN" "$dir/artisan" "$@"
        return $?
      fi
      dir=$(dirname "$dir")
    done

    echo "ERROR: artisan not found in current directory ($PWD). Run this from a Laravel project root." >&2
    return 1
  }

  start_artisan_server() {
    read "port?Enter port [$LARAVEL_PORT]: "
    port=${port:-$LARAVEL_PORT}
    echo "Serving Laravel on http://$LARAVEL_HOST:$port (background)"
    "$PHP_BIN" artisan serve --host="$LARAVEL_HOST" --port="$port" >/dev/null 2>&1 &
    ARTISAN_SERV_PID=$!
    sleep 0.1
    local pids=("$ARTISAN_SERV_PID")
    pids+=( $(pgrep -P "$ARTISAN_SERV_PID" 2>/dev/null) )
    pids+=( $(pgrep -f "vendor/laravel/framework.*server\.php" 2>/dev/null) )
    pids=("${(@u)pids}")
    ARTISAN_PIDFILE="$PWD/.artisan_serve.pids"
    printf "%s\n" "${pids[@]}" >| "$ARTISAN_PIDFILE"
    echo "Started artisan serve (PIDs: ${pids[*]}). PID file: $ARTISAN_PIDFILE"
  }

  stop_artisan_server() {
    local stopped=0
    local pidfile="$PWD/.artisan_serve.pids"
    local pids=()
    local kill_pids=()

    if [[ -f "$pidfile" ]]; then
      pids=()
      while IFS= read -r line; do
        pids+=("$line")
      done < "$pidfile"
    fi

    # if no pidfile or empty, fall back to pgrep
    if [[ ${#pids[@]} -eq 0 ]]; then
      pids=( $(pgrep -f "vendor/laravel/framework.*server\.php" 2>/dev/null) )
    fi

    if [[ ${#pids[@]} -eq 0 ]]; then
      echo "WARN: No artisan serve processes found."
      return
    fi

    for pid in "${pids[@]}"; do
      [[ -z "$pid" ]] && continue
      kill_pids+=("$pid")
      kill_pids+=( $(pgrep -P "$pid" 2>/dev/null) )
    done
    kill_pids+=( $(pgrep -f "vendor/laravel/framework.*server\.php" 2>/dev/null) )
    kill_pids=("${(@u)kill_pids}")

    if [[ ${#kill_pids[@]} -eq 0 ]]; then
      echo "WARN: No artisan serve processes found."
      return
    fi

    for pid in "${kill_pids[@]}"; do
      [[ -z "$pid" ]] && continue
      if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null && stopped=1
      fi
    done

    sleep 0.4

    local still_running=()
    for pid in "${kill_pids[@]}"; do
      [[ -z "$pid" ]] && continue
      if kill -0 "$pid" 2>/dev/null; then
        still_running+=("$pid")
      fi
    done

    if [[ ${#still_running[@]} -gt 0 ]]; then
      echo "Some artisan serve processes are still running; sending SIGKILL..."
      for pid in "${still_running[@]}"; do
        kill -9 "$pid" 2>/dev/null && stopped=1
      done
    fi

    for pid in "${kill_pids[@]}"; do
      [[ -z "$pid" ]] && continue
      if ! kill -0 "$pid" 2>/dev/null; then
        echo "Stopped artisan serve PID $pid"
      fi
    done

    if [[ -f "$pidfile" ]]; then
      rm -f "$pidfile"
    fi

    if [[ $stopped -eq 0 ]]; then
      echo "WARN: No artisan serve processes were stopped."
    fi
  }

  artisan_migrate()          { artisan_exec migrate; }
  artisan_migrate_fresh()    { artisan_exec migrate:fresh; }
  artisan_migrate_rollback() { artisan_exec migrate:rollback; }
  artisan_migrate_status()   { artisan_exec migrate:status; }
  artisan_db_seed()          { artisan_exec db:seed; }
  artisan_db_seed_permissions() {
    artisan_exec migrate || return $?
    artisan_exec db:seed --class=PermissionSeeder
  }
  artisan_deploy() {
    artisan_exec migrate || return $?
    artisan_exec db:seed --class=PermissionSeeder || return $?
    artisan_exec migrate:status || return $?
    artisan_exec optimize:clear || return $?
    artisan_exec view:clear || return $?
    artisan_exec cache:clear || return $?
    artisan_exec config:clear || return $?
  }
  artisan_cache_clear()      { artisan_exec cache:clear; }
  artisan_config_cache()     { artisan_exec config:cache; }
  artisan_route_cache()      { artisan_exec route:cache; }
  artisan_view_clear()       { artisan_exec view:clear; }
  artisan_storage_link()     { artisan_exec storage:link; }
  artisan_key_generate()     { artisan_exec key:generate; }
  artisan_test()             { artisan_exec test; }
  artisan_tinker()           { artisan_exec tinker; }
  artisan_queue_work()       { artisan_exec queue:work "$@"; }

  make_controller()  { read "name?Controller name: "; artisan_exec make:controller "$name"; }
  make_model()       { read "name?Model name: "; artisan_exec make:model "$name"; }
  make_migration()   { read "name?Migration name: "; artisan_exec make:migration "$name"; }
  make_middleware()  { read "name?Middleware name: "; artisan_exec make:middleware "$name"; }

  # Interactive menu loop (behaves like `mdb`): run chosen command, then
  # wait for Enter to continue. Type 'q' at the prompt to exit the loop.
  run_command() {
    local cmd="$1"
    eval "$cmd"
    echo
    read -k 1 -r "PAUSE?Press Enter to continue or q to quit..."
    echo
    if [[ "$PAUSE" == "q" || "$PAUSE" == "Q" ]]; then
      EXIT_NOW=1
    fi
  }

  local EXIT_NOW=0
  while true; do
    local choice
    local plain_choice
    # Use reverse layout so Serve is highlighted by default; bias matches to start
    choice=$(printf "%s\n" "${menu[@]}" | fzf --ansi --height 20 --layout=reverse --tiebreak=begin --prompt "Laravel › " --border)

    plain_choice=$(print -r -- "$choice" | sed $'s/\x1B\\[[0-9;]*[A-Za-z]//g')
    [[ -z "$plain_choice" || "$plain_choice" == "$quit_label" ]] && break
    run_command "${commands[$plain_choice]}"
    if [[ $EXIT_NOW -eq 1 ]]; then
      break
    fi
  done
}

# Short aliases to call functions directly
alias laravel:serve='laravel && start_artisan_server'
alias laravel:stop='laravel && stop_artisan_server'

# Combined clear: run both `view:clear` and `cache:clear` in project root (or ancestors)
artisan_clear_all() {
  local php="${PHP_BIN:-php83}"
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/artisan" ]]; then
      "$php" "$dir/artisan" view:clear
      "$php" "$dir/artisan" cache:clear
      return $?
    fi
    dir=$(dirname "$dir")
  done

  echo "ERROR: artisan not found in current directory ($PWD). Run from a Laravel project root." >&2
  return 1
}

alias laravel:clear='artisan_clear_all'

# End of file
