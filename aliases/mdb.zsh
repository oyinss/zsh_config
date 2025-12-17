#!/bin/zsh

mdb() {
  local UPDATE_SCRIPT="~/Apex/pisol/cba/scripts/update_local_pisol_db.sh"

  declare -A commands=(
    ["▶️ Start MariaDB"]="sudo systemctl start mariadb"
    ["⏹ Stop MariaDB"]="sudo systemctl stop mariadb"
    ["🔄 Restart MariaDB"]="sudo systemctl restart mariadb"
    ["📊 Check MariaDB Status"]="sudo systemctl status mariadb"
    ["🔐 Log into MariaDB"]="mysql -u root -p"
    ["📋 List Databases"]="mysql -u root -p -e 'SHOW DATABASES;'"
    ["➕ Create New Database"]="create_database"
    ["🗑 Drop Database"]="drop_database"
    ["👤 Create New User"]="create_user"
    ["🔑 Change User Password"]="change_user_password"
    ["📂 List Tables in Database"]="list_tables"
    ["💾 Backup Database"]="backup_database"
    ["♻️ Restore Database"]="restore_database"
    ["🔄 Update Local Pisol DB"]="run_update_script"
    ["🚪 Quit"]=":"
  )

  run_update_script() {
    if [[ ! -f "$UPDATE_SCRIPT" ]]; then
      echo "❌ Update script not found:"
      echo "   $UPDATE_SCRIPT"
      return 1
    fi

    if [[ ! -x "$UPDATE_SCRIPT" ]]; then
      chmod +x "$UPDATE_SCRIPT"
    fi

    echo "🚀 Running local Pisol DB update..."
    "$UPDATE_SCRIPT"
  }

  create_database() {
    read "dbname?Database name: "
    mysql -u root -p -e "CREATE DATABASE \`$dbname\`;"
  }

  drop_database() {
    read "dbname?Database to drop: "
    mysql -u root -p -e "DROP DATABASE \`$dbname\`;"
  }

  create_user() {
    read "username?Username: "
    read -s "password?Password: "
    echo
    mysql -u root -p -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
  }

  change_user_password() {
    read "username?Username: "
    read -s "password?New password: "
    echo
    mysql -u root -p -e "ALTER USER '$username'@'localhost' IDENTIFIED BY '$password';"
  }

  list_tables() {
    read "dbname?Database name: "
    mysql -u root -p "$dbname" -e "SHOW TABLES;"
  }

  backup_database() {
    read "dbname?Database to backup: "
    read "filepath?Backup file path: "
    mysqldump -u root -p "$dbname" > "$filepath"
  }

  restore_database() {
    read "filepath?Backup file path: "
    read "dbname?Restore into database: "
    mysql -u root -p "$dbname" < "$filepath"
  }

  while true; do
    local choice=$(printf "%s\n" "${(@k)commands}" | fzf \
      --height 20 \
      --prompt "🐬 MariaDB Manager: " \
      --border)

    [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && break
    eval "${commands[$choice]}"
  done
}
