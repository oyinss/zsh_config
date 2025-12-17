#!/bin/zsh

jctl() {
  local service=$(systemctl list-units --type=service --all --no-pager --no-legend \
    | awk '{print $1}' | fzf --prompt="🛎️ Select service for logs: " --height=15)

  if [[ -z "$service" ]]; then
    echo "❌ No service selected."
    return 1
  fi

  echo "🟢 Selected service: $service"

  local action=$(printf "🕒 Show recent logs (last 50 lines)\n▶️ Follow logs (live)\n📅 Show logs since today\n📜 Show full logs\n🚪 Quit" \
    | fzf --prompt="📚 Choose journalctl action: " --height=7)

  case "$action" in
    "🕒 Show recent logs (last 50 lines)")
      journalctl -u "$service" -n 50 --no-pager
      ;;
    "▶️ Follow logs (live)")
      echo "Press Ctrl+C to exit live logs."
      journalctl -u "$service" -f
      ;;
    "📅 Show logs since today")
      journalctl -u "$service" --since today --no-pager
      ;;
    "📜 Show full logs")
      journalctl -u "$service" --no-pager
      ;;
    "🚪 Quit"|*)
      echo "🚪 Exiting."
      ;;
  esac
}

