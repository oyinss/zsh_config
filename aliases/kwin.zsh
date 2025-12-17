#!/bin/zsh

meta() {
  typeset -A actions=(
    ["🎯 Set Meta to KRunner"]="kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta \"org.kde.krunner,/App,,toggleDisplay\" && qdbus org.kde.KWin /KWin reconfigure"
    ["📦 Set Meta to Application Launcher"]="kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta \"org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu\" && qdbus org.kde.KWin /KWin reconfigure"
    ["🪟 Set Meta to ExposeAll"]="kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta \"org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,ExposeAll\" && qdbus org.kde.KWin /KWin reconfigure"
    ["🧭 Set Meta to Overview"]="kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta \"org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Overview\" && qdbus org.kde.KWin /KWin reconfigure"
    ["❌ Disable Meta Key"]="kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta \"\" && qdbus org.kde.KWin /KWin reconfigure"
    ["🔍 List Meta Bindings"]="qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.shortcutNames"
    ["🔁 Reload KWin"]="qdbus org.kde.KWin /KWin reconfigure"
    ["🚪 Quit"]="return"
  )

  local choice=$(printf "%s\n" "${(@k)actions}" | fzf --height=14 --prompt="🪟  Meta Key Menu: " --border)

  if [[ -n $choice ]]; then
    eval "${actions[$choice]}"
  else
    echo "❌ No action selected."
  fi
}

