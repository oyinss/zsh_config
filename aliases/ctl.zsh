#!/bin/zsh

# --------------------------------------------------------
# Systemctl Services and Control
# --------------------------------------------------------
alias ctlprocess="sudo systemctl --failed"
alias ctlservices="systemctl list-unit-files --type=service"
alias ctllist="systemctl list-unit-files --type=service"
alias ctlreload="sudo systemctl daemon-reload"
alias ctlenable="sudo systemctl enable"
alias ctlstart="sudo systemctl start"
alias ctlrestart="sudo systemctl restart"
alias ctlstatus="sudo systemctl status"

ctl() {
  echo "🔄 Reloading systemd daemon..."
  sudo systemctl daemon-reload

  local service=$(systemctl list-units --type=service --all --no-pager --no-legend \
    | awk '{print $1}' | fzf --prompt="🛎️ Select service: " --height=15)

  if [[ -z "$service" ]]; then
    echo "❌ No service selected."
    return 1
  fi

  echo "🟢 Selected: $service"

  local action=$(printf "✅ Enable now\n⛔ Disable now\n▶️ Start\n🔄 Restart\n📋 Status\n🚪 Cancel" | fzf --prompt="⚙️ Action: " --height=7)

  case "$action" in
    "✅ Enable now")
      sudo systemctl enable "$service"
      echo "✅ Enabled $service"
      ;;
    "⛔ Disable now")
      sudo systemctl disable "$service"
      echo "⛔ Disabled $service"
      ;;
    "▶️ Start")
      sudo systemctl start "$service"
      echo "▶️ Started $service"
      ;;
    "🔄 Restart")
      sudo systemctl restart "$service"
      echo "🔄 Restarted $service"
      ;;
    "📋 Status")
      systemctl status "$service"
      ;;
    "🚪 Cancel"|*)
      echo "🚪 Cancelled."
      ;;
  esac
}

