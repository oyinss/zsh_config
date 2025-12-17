#!/bin/zsh

flut() {
  typeset -A commands=(
    ["🩺 Doctor"]="flutter doctor"
    ["⬆️ Upgrade Project"]="flutter upgrade"
    ["⬆️ Update SDK (git pull)"]="update_sdk"
    ["📦 Get Packages"]="flutter pub get"
    ["🧹 Clean"]="flutter clean"
    ["🔨 Build APK"]="flutter build apk --release"
    ["📱 Build AppBundle"]="flutter build appbundle --release"
    ["🌐 Build Web (auto renderer)"]="flutter build web --release"
    ["🌐 Build Web (html)"]="flutter build web --release --web-renderer html"
    ["🌐 Build Web (canvaskit)"]="flutter build web --release --web-renderer canvaskit"
    ["▶️ Run on Device"]="flutter run"
    ["▶️ Run Web"]="flutter run -d chrome"
    ["📋 Devices"]="flutter devices"
    ["📜 Analyze"]="flutter analyze"
    ["🐞 Test"]="flutter test"
    ["📝 Create Project"]="create_project"
    ["🚪 Quit"]="return"
  )

  local choice=$(printf "%s\n" "${(@k)commands}" | fzf --height=20 --prompt="🦋 Flutter Menu: " --border)

  if [[ -n $choice ]]; then
    eval "${commands[$choice]}"
  else
    echo "❌ No option selected."
  fi
}

update_sdk() {
  (cd ~/flutter && git pull && flutter upgrade)
}

create_project() {
  echo -n "Enter project name: "
  read pname
  if [[ -n "$pname" ]]; then
    flutter create "$pname" && echo "✅ Project created: $pname"
  else
    echo "❌ No name entered."
  fi
}

