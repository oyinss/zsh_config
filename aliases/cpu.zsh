#!/bin/zsh

# Function to update a specific section of auto-cpufreq.conf
change_cpu_mode() {
  local mode=$1
  local section=$2
  local conf="/etc/auto-cpufreq.conf"

  local preference
  case $mode in
    performance) preference="performance" ;;
    schedutil|ondemand) preference="balance_performance" ;;
    conservative|powersave) preference="power" ;;
    *) preference="default" ;;
  esac

  sudo sed -i "/^\[$section\]/,/^\[.*\]/ {
    s/^governor = .*/governor = $mode/
    s/^energy_performance_preference = .*/energy_performance_preference = $preference/
    s/^turbo = .*/turbo = never/
  }" $conf

  echo "✅ [$section] governor set to $mode (energy_pref: $preference)"
}

cpu() {
  local options=(
    # View/edit system info
    "📊 View CPU Stats"
    "🔍 Check CPU Governor"
    "🛠 Edit Auto-CPUFreq Config (System)"

    # Auto-CPUFreq service control
    "▶️ Start Auto-CPUFreq"
    "⏹ Stop Auto-CPUFreq"

    # Governor: Charger
    "🔌 performance"
    "🔌 schedutil"
    "🔌 userspace"
    "🔌 ondemand"
    "🔌 conservative"
    "🔌 powersave"

    # Governor: Battery
    "🔋 performance"
    "🔋 schedutil"
    "🔋 userspace"
    "🔋 ondemand"
    "🔋 conservative"
    "🔋 powersave"

    # Exit
    "🚪 Quit"
  )

  local choice=$(printf "%s\n" "${options[@]}" | fzf --height 22 --prompt "⚙️  Select CPU Option: " --border)

  case $choice in
    "📊 View CPU Stats") sudo auto-cpufreq --stats ;;
    "🔍 Check CPU Governor") cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ;;
    "🛠 Edit Auto-CPUFreq Config (System)") sudo nvim /etc/auto-cpufreq.conf ;;

    "▶️ Start Auto-CPUFreq") sudo auto-cpufreq --install ;;
    "⏹ Stop Auto-CPUFreq") sudo auto-cpufreq --remove ;;

    "🔌 performance") change_cpu_mode performance charger ;;
    "🔌 schedutil") change_cpu_mode schedutil charger ;;
    "🔌 userspace") change_cpu_mode userspace charger ;;
    "🔌 ondemand") change_cpu_mode ondemand charger ;;
    "🔌 conservative") change_cpu_mode conservative charger ;;
    "🔌 powersave") change_cpu_mode powersave charger ;;

    "🔋 performance") change_cpu_mode performance battery ;;
    "🔋 schedutil") change_cpu_mode schedutil battery ;;
    "🔋 userspace") change_cpu_mode userspace battery ;;
    "🔋 ondemand") change_cpu_mode ondemand battery ;;
    "🔋 conservative") change_cpu_mode conservative battery ;;
    "🔋 powersave") change_cpu_mode powersave battery ;;

    "🚪 Quit") return ;;
    *) echo "❌ Invalid selection." ;;
  esac
}
