#!/bin/zsh

alias msql="mariadb"

mdb() {
  local UPDATE_SCRIPT="$HOME/Apex/pisol/cba/scripts/db_update.sh"

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
    ["🔐 Setup DB Credentials"]="setup_db_creds"
    ["📂 List Tables in Database"]="list_tables"
    ["💾 Backup Database"]="backup_database"
    ["♻️ Restore Database"]="restore_database"
    ["📤 Export to CSV"]="export_to_csv"
    ["🔄 Update Pisol Local DB"]="run_update_script"
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

    echo "🚀 Running Pisol local DB update..."
    # If user has ~/.my.cnf with a password, export it temporarily so the update script can run passwordless
    if [[ -r "$HOME/.my.cnf" ]]; then
      cfg_pass=$(grep -iE '^[[:space:]]*password[[:space:]]*=' "$HOME/.my.cnf" | head -n1 | sed 's/.*=//;s/[[:space:]]*//g')
      if [[ -n "$cfg_pass" ]]; then
        MYSQL_PWD="$cfg_pass" "$UPDATE_SCRIPT"
      else
        "$UPDATE_SCRIPT"
      fi
    else
      "$UPDATE_SCRIPT"
    fi
    # Set a flag to break the main loop after update
    UPDATE_DONE=1
    return 0
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

  setup_db_creds() {
    read "dbuser?DB user (default: $USER): "
    dbuser=${dbuser:-$USER}
    read -s "dbpass?Password for $dbuser: "
    echo
    cat > "$HOME/.my.cnf" <<EOF
[client]
user=$dbuser
password=$dbpass
host=localhost
EOF
    chmod 600 "$HOME/.my.cnf"
    echo "✅ Saved credentials to $HOME/.my.cnf (permissions 600)"
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

  export_to_csv() {
    read "query?Paste your SELECT query: "
    read "dbname?Database (leave blank if your query uses database.table): "
    dbname=$(echo "$dbname" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if echo "$query" | grep -iqE '[[:alnum:]_]+\.[[:alnum:]_]+'; then
      dbname=""
    fi
    local tbl=$(echo "$query" | grep -o -E 'from[[:space:]]+([a-zA-Z0-9_]+)' | awk '{print $2}' | head -n1)
    [[ -z "$tbl" ]] && tbl="export"
    local ts=$(date +%Y%m%d_%H%M%S)
    local outdir="$(pwd)/csv"
    mkdir -p "$outdir"
    local suggested
    local where_kv=$(echo "$query" | grep -io -E "where[[:space:]]+[[:alnum:]_]+[[:space:]]*=[[:space:]]*'[^']+'" | head -n1)
    if [[ -n "$where_kv" ]]; then
      local col=$(echo "$where_kv" | sed -E "s/where[[:space:]]+([[:alnum:]_]+)[[:space:]]*=.*/\1/I")
      local val=$(echo "$where_kv" | sed -E "s/.*=[[:space:]]*'([^']+)'.*/\1/")
      suggested="${tbl}_${col}_${val}"
    else
      suggested="$tbl"
    fi
    suggested="${suggested}_${ts}.csv"
    read "fname?Filename (default: $suggested): "
    fname=${fname:-$suggested}
    fname=$(echo "$fname" | tr ' ' '_' | tr -d '"')
    local outfile="$outdir/$fname"
    query=$(echo "$query" | sed 's/;[[:space:]]*$//')
    echo "Running export..."
    read "dbuser?DB user (default: $USER): "
    dbuser=${dbuser:-$USER}
    # Always use passwordless if ~/.my.cnf exists and has user/password, regardless of dbuser prompt
    use_pw_flag="-p"
    if [[ -r "$HOME/.my.cnf" ]]; then
      if grep -iqE '^[[:space:]]*user[[:space:]]*=' "$HOME/.my.cnf" && grep -iqE '^[[:space:]]*password[[:space:]]*=' "$HOME/.my.cnf"; then
        use_pw_flag=""
      fi
    fi
    if [[ -n "$dbname" ]]; then
      if [[ -n "$use_pw_flag" ]]; then
        mariadb -u "$dbuser" $use_pw_flag -D"$dbname" -B -e "$query" | sed $'s/\t/;/g' > "$outfile"
      else
        mariadb -u "$dbuser" -D"$dbname" -B -e "$query" | sed $'s/\t/;/g' > "$outfile"
      fi
    else
      if [[ -n "$use_pw_flag" ]]; then
        mariadb -u "$dbuser" $use_pw_flag -B -e "$query" | sed $'s/\t/;/g' > "$outfile"
      else
        mariadb -u "$dbuser" -B -e "$query" | sed $'s/\t/;/g' > "$outfile"
      fi
    fi
    if [[ $? -eq 0 && -s "$outfile" ]]; then
      echo "✅ Exported to $outfile"
      UPDATE_DONE=1
      return 0
    else
      echo "❌ Export failed. Check permissions, credentials and query syntax."
    fi
  }

  UPDATE_DONE=0
  while true; do
    local choice=$(printf "%s\n" "${(@k)commands}" | fzf \
      --height 20 \
      --prompt "🐬 MariaDB Manager: " \
      --border)

    [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && break
    eval "${commands[$choice]}"
    if [[ $UPDATE_DONE -eq 1 ]]; then
      break
    fi
  done
}
