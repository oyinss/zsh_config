#!/bin/zsh

dok() {
  typeset -A commands=(
    ["🔍 Running Containers"]="docker PS"
    ["📋 All Containers"]="docker ps -a"
    ["🐳 Show Containers"]="docker ps -a"
    ["🧾 Compose PS"]="docker compose ps"
    ["📦 Show Images"]="docker images"
    ["🔥 System Prune"]="docker system prune -af"
    ["🧹 Remove All Containers & Images"]="docker rm -f \$(docker ps -aq) && docker rmi -f \$(docker images -q)"
    ["❌ Remove Container"]="remove_container"
    ["▶️ Start Container"]="start_container"
    ["⏹️ Stop Container"]="stop_container"
    ["🔴 Stop All Containers"]="docker stop \$(docker ps -q)"
    ["🔄 Restart Container"]="restart_container"
    ["📋 Logs (Follow)"]="logs_container"
    ["🖥️ Exec Shell (sh)"]="sh_container"
    ["🐚 Exec Shell (bash)"]="bash_container"
    ["🚀 Run Container"]="run_container"
    ["🏗️ Compose Build"]="docker-compose build"
    ["⬆️ Compose Up"]="docker-compose up -d"
    ["⬇️ Compose Down"]="docker-compose down"
    ["🔁 Compose Restart"]="docker-compose down && docker-compose up -d"
    ["💻 Compose Exec"]="compose_exec"
    ["🚪 Quit"]="return"
  )

  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height=20 --prompt="🐳  Docker Menu: " --border)

  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ No option selected."
  fi
}

start_container() {
  local id=$(docker ps -a --format '{{.Names}}' | fzf --prompt="▶️ Start: ")
  [[ -n "$id" ]] && docker start "$id" && echo "✅ Started: $id"
}

stop_container() {
  local id=$(docker ps --format '{{.Names}}' | fzf --prompt="⏹️ Stop: ")
  [[ -n "$id" ]] && docker stop "$id" && echo "⏹️ Stopped: $id"
}

restart_container() {
  local id=$(docker ps --format '{{.Names}}' | fzf --prompt="🔄 Restart: ")
  [[ -n "$id" ]] && docker restart "$id" && echo "🔄 Restarted: $id"
}

remove_container() {
  local id=$(docker ps -a --format '{{.Names}}' | fzf --prompt="❌ Remove: ")
  [[ -n "$id" ]] && docker rm -f "$id" && echo "✅ Removed: $id"
}

logs_container() {
  local id=$(docker ps --format '{{.Names}}' | fzf --prompt="📋 Logs: ")
  [[ -n "$id" ]] && docker logs -f "$id"
}

sh_container() {
  local id=$(docker ps --format '{{.Names}}' | fzf --prompt="🖥️ sh: ")
  [[ -n "$id" ]] && docker exec -it "$id" sh
}

bash_container() {
  local id=$(docker ps --format '{{.Names}}' | fzf --prompt="🐚 bash: ")
  [[ -n "$id" ]] && docker exec -it "$id" bash
}

run_container() {
  echo "⚠️  Example: ubuntu bash"
  echo -n "Enter image + args: "
  read cmd
  [[ -n "$cmd" ]] && docker run --rm -it $cmd
}

compose_exec() {
  echo -n "Service name: "
  read svc
  echo -n "Command (e.g., sh): "
  read cmd
  [[ -n "$svc" && -n "$cmd" ]] && docker-compose exec "$svc" "$cmd"
}

