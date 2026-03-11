#!/bin/zsh

alias msql="mariadb"

mdb() {
  local UPDATE_SCRIPT="$HOME/Apex/pisol/cba/scripts/db_update.sh"

  declare -A commands=(
    ["▶️ Start MariaDB"]="sudo systemctl start mariadb"
    ["⏹ Stop MariaDB"]="sudo systemctl stop mariadb"
    ["🔄 Restart MariaDB"]="sudo systemctl restart mariadb"
    ["📊 Check MariaDB Status"]="sudo systemctl status mariadb"
      ["🔐 Log into MariaDB"]="run_root_client"
      ["📋 List Databases"]="run_root_client -e 'SHOW DATABASES;'"
      ["👥 List DB Users"]="list_users"
    ["➕ Create New Database"]="create_database"
    ["➕ Create DB + User"]="create_db_and_user"
    ["🗑 Drop Database"]="drop_database"
    ["👤 Create New User"]="create_user"
    ["🔑 Change User Password"]="change_user_password"
    ["🗑 Drop DB User"]="drop_user"
    ["🔐 Setup DB Credentials"]="setup_db_creds"
    ["📂 List Tables in Database"]="list_tables"
    ["💾 Backup Database"]="backup_database"
    ["♻️ Restore Database"]="restore_database"
    ["📤 Export to CSV"]="export_to_csv"
    ["🔄 Update CBA Local DB"]="run_update_script"
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

    echo "🚀 Running CBA local DB update..."
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
    run_root_client -e "CREATE DATABASE \`$dbname\`;"
  }

  drop_database() {
    read "dbname?Database to drop: "
    run_root_client -e "DROP DATABASE \`$dbname\`;"
  }

  create_user() {
    read "username?Username: "
    read -s "password?Password: "
    echo
    run_root_client -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
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
    run_root_client -e "ALTER USER '$username'@'localhost' IDENTIFIED BY '$password';"
  }

  list_tables() {
    read "dbname?Database name: "
    run_root_client -D"$dbname" -e "SHOW TABLES;"
  }

  backup_database() {
    read "dbname?Database to backup: "
    read "filepath?Backup file path: "
    run_mysqldump "$dbname" > "$filepath"
  }

  restore_database() {
    read "filepath?Backup file path: "
    read "dbname?Restore into database: "
    run_root_client -D"$dbname" < "$filepath"
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

  list_users() {
    run_root_client -e "SELECT User,Host,plugin FROM mysql.user ORDER BY User,Host;"
  }

  create_db_and_user() {
    read "dbname?Database name: "
    read "username?Username: "
    read "host?Host (default: localhost): "
    host=${host:-localhost}
    read -s "password?Password for $username: "
    echo
    echo "Creating database (if not exists) and user..."
    run_root_client -e "CREATE DATABASE IF NOT EXISTS \`$dbname\`;"
    run_root_client -e "CREATE USER IF NOT EXISTS '$username'@'$host' IDENTIFIED BY '$password'; ALTER USER '$username'@'$host' IDENTIFIED BY '$password'; GRANT ALL PRIVILEGES ON \`$dbname\`.* TO '$username'@'$host'; FLUSH PRIVILEGES;"
    echo
    run_root_client -e "SHOW GRANTS FOR '$username'@'$host';"
  }

  drop_user() {
    read "username?Username to drop: "
    read "host?Host (default: localhost): "
    host=${host:-localhost}
    echo
    echo "Checking user entry for '$username'@'$host'..."
    run_root_client -e "SELECT User,Host FROM mysql.user WHERE User='$username' AND Host='$host';"
    echo
    echo "Current grants for $username@$host:"
    run_root_client -e "SHOW GRANTS FOR '$username'@'$host';"
    echo
    read "confirm?Type DROP to confirm deletion: "
    if [[ "$confirm" == "DROP" ]]; then
      run_root_client -e "DROP USER IF EXISTS '$username'@'$host';"
      echo "✅ DROP executed (if the user existed)."
    else
      echo "Cancelled — user not dropped."
    fi
  }

    # Run mariadb client as configured user if ~/.my.cnf exists, otherwise via sudo
    run_root_client() {
      if [[ -r "$HOME/.my.cnf" ]] && grep -iqE '^[[:space:]]*password[[:space:]]*=' "$HOME/.my.cnf"; then
        mariadb "$@"
      else
        sudo mariadb "$@"
      fi
    }

    # Run mysqldump using ~/.my.cnf credentials if available, else via sudo
    run_mysqldump() {
      if [[ -r "$HOME/.my.cnf" ]] && grep -iqE '^[[:space:]]*password[[:space:]]*=' "$HOME/.my.cnf"; then
        mysqldump "$@"
      else
        sudo mysqldump "$@"
      fi
    }

  run_command() {
    local cmd="$1"
    eval "$cmd"
    echo
    read -r "PAUSE?Press Enter to continue..."
  }

  UPDATE_DONE=0
  while true; do
    local choice=$(printf "%s\n" "${(@k)commands}" | fzf \
      --height 20 \
      --prompt "🐬 MariaDB Manager: " \
      --border)

    [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && break
    run_command "${commands[$choice]}"
    if [[ $UPDATE_DONE -eq 1 ]]; then
      break
    fi
  done
}
