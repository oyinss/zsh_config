#!/bin/zsh

alias mysql="mariadb"

mdb() {
  local reset=$'\033[0m'
  local blue=$'\033[38;5;75m'
  local cyan=$'\033[38;5;80m'
  local green=$'\033[38;5;114m'
  local yellow=$'\033[38;5;221m'
  local purple=$'\033[38;5;141m'
  local red=$'\033[38;5;203m'
  local orange=$'\033[38;5;208m'

  if [[ $# -gt 0 ]]; then
    case "$1" in
      exec|sql|-e)
        shift
        local dbname=""
        if [[ "$1" == "-D" || "$1" == "--database" ]]; then
          shift
          if [[ $# -eq 0 ]]; then
            echo "Usage: mdb exec -D dbname 'SQL statement;' or mdb exec -D dbname <<'SQL'"
            return 1
          fi
          dbname="$1"
          shift
        elif [[ $# -gt 1 ]]; then
          case "$2" in
            [Uu][Pp][Dd][Aa][Tt][Ee]*|[Ii][Nn][Ss][Ee][Rr][Tt]*|[Dd][Ee][Ll][Ee][Tt][Ee]*|[Ss][Ee][Ll][Ee][Cc][Tt]*|[Cc][Rr][Ee][Aa][Tt][Ee]*|[Aa][Ll][Tt][Ee][Rr]*|[Dd][Rr][Oo][Pp]*|[Uu][Ss][Ee]*)
              dbname="$1"
              shift
              ;;
          esac
        fi

        local sql=""
        if [[ $# -gt 0 ]]; then
          sql="$*"
        elif [[ ! -t 0 ]]; then
          sql="$(cat)"
        else
          echo "Usage: mdb exec [-D dbname] 'SQL statement;' or mdb exec [-D dbname] <<'SQL'"
          return 1
        fi

        if [[ -z "${sql//[[:space:]]/}" ]]; then
          echo "ERROR: Empty SQL payload."
          return 1
        fi

        if [[ -z "$dbname" ]]; then
          read "dbname?Database name (press Enter to use current connection): "
        fi

        echo "Executing SQL..."
        if [[ -n "$dbname" ]]; then
          run_root_client -D"$dbname" -e "$sql"
        else
          run_root_client -e "$sql"
        fi
        return $?
        ;;
      *)
        echo "Unknown mdb command: $1"
        return 1
        ;;
    esac
  fi

  local start_label=" Start MariaDB"
  local stop_label="󰓛 Stop MariaDB"
  local restart_label="󰑓 Restart MariaDB"
  local status_label="󰄬 Check MariaDB Status"
  local login_label="󰌾 Log into MariaDB"
  local login_db_label="󰆼 Log into MariaDB Database"
  local sql_label=" Execute Raw SQL"
  local list_db_label="󰆼 List Databases"
  local list_users_label="󰀄 List DB Users"
  local create_db_label="󰆼 Create New Database"
  local create_db_user_label="󰌾 Create DB + User"
  local drop_db_label="󰆴 Drop Database"
  local recreate_db_label="󰜉 Recreate Database"
  local update_db_label="󰚰 Update DB"
  local create_user_label="󰀄 Create New User"
  local password_label="󰌋 Change User Password"
  local drop_user_label="󰆴 Drop DB User"
  local creds_label="󰌾 Setup DB Credentials"
  local tables_label="󰓫 List Tables in Database"
  local backup_label="󰆓 Backup Database"
  local restore_label="󰑕 Restore Database"
  local csv_label="󰈙 Export to CSV"
  local quit_label="󰅙 Quit"

  declare -A commands=(
    ["$start_label"]="sudo systemctl start mariadb"
    ["$stop_label"]="sudo systemctl stop mariadb"
    ["$restart_label"]="sudo systemctl restart mariadb"
    ["$status_label"]="sudo systemctl status mariadb"
    ["$login_label"]="run_root_client"
    ["$login_db_label"]="login_database"
    ["$sql_label"]="execute_sql"
    ["$list_db_label"]="run_root_client -e 'SHOW DATABASES;'"
    ["$list_users_label"]="list_users"
    ["$create_db_label"]="create_database"
    ["$create_db_user_label"]="create_db_and_user"
    ["$drop_db_label"]="drop_database"
    ["$recreate_db_label"]="recreate_database"
    ["$update_db_label"]="update_database"
    ["$create_user_label"]="create_user"
    ["$password_label"]="change_user_password"
    ["$drop_user_label"]="drop_user"
    ["$creds_label"]="setup_db_creds"
    ["$tables_label"]="list_tables"
    ["$backup_label"]="backup_database"
    ["$restore_label"]="restore_database"
    ["$csv_label"]="export_to_csv"
    ["$quit_label"]=":"
  )

  local -a menu=(
    "${green}${reset} ${purple}Start MariaDB${reset}"
    "${red}󰓛${reset} ${purple}Stop MariaDB${reset}"
    "${yellow}󰑓${reset} ${purple}Restart MariaDB${reset}"
    "${cyan}󰄬${reset} ${purple}Check MariaDB Status${reset}"
    "${orange}󰌾${reset} ${purple}Log into MariaDB${reset}"
    "${yellow}󰆼${reset} ${purple}Log into MariaDB Database${reset}"
    "${blue}${reset} ${purple}Execute Raw SQL${reset}"
    "${yellow}󰆼${reset} ${purple}List Databases${reset}"
    "${cyan}󰀄${reset} ${purple}List DB Users${reset}"
    "${green}󰆼${reset} ${purple}Create New Database${reset}"
    "${green}󰌾${reset} ${purple}Create DB + User${reset}"
    "${red}󰆴${reset} ${purple}Drop Database${reset}"
    "${orange}󰜉${reset} ${purple}Recreate Database${reset}"
    "${green}󰚰${reset} ${purple}Update DB${reset}"
    "${green}󰀄${reset} ${purple}Create New User${reset}"
    "${yellow}󰌋${reset} ${purple}Change User Password${reset}"
    "${red}󰆴${reset} ${purple}Drop DB User${reset}"
    "${orange}󰌾${reset} ${purple}Setup DB Credentials${reset}"
    "${cyan}󰓫${reset} ${purple}List Tables in Database${reset}"
    "${blue}󰆓${reset} ${purple}Backup Database${reset}"
    "${yellow}󰑕${reset} ${purple}Restore Database${reset}"
    "${cyan}󰈙${reset} ${purple}Export to CSV${reset}"
    "${red}󰅙${reset} ${purple}Quit${reset}"
  )

  execute_sql() {
    read "dbname?Database name (leave blank to use current connection): "
    echo "Enter SQL to execute. Finish with a blank line."
    local sql=""
    local line
    while IFS= read -r line; do
      [[ -z "$line" ]] && break
      sql+="$line\n"
    done
    if [[ -z "${sql//[[:space:]]/}" ]]; then
      echo "ERROR: No SQL entered."
      return 1
    fi
    if [[ -n "$dbname" ]]; then
      run_root_client -D"$dbname" -e "$sql"
    else
      run_root_client -e "$sql"
    fi
  }

  create_database() {
    read "dbname?Database name: "
    run_root_client -e "CREATE DATABASE \`$dbname\`;"
  }

  login_database() {
    read "dbname?Database name: "
    if [[ -z "$dbname" ]]; then
      echo "ERROR: No database selected."
      return 1
    fi
    run_root_client -D"$dbname"
  }

  drop_database() {
    read "dbname?Database to drop: "
    run_root_client -e "DROP DATABASE \`$dbname\`;"
  }

   recreate_database() {
     read "dbname?Database to recreate: "
     echo
     echo "WARNING: This will DROP the database if it exists and then CREATE it anew."
     read "confirm?Proceed? (y/N): "
     case "$confirm" in
       y|Y|yes|YES|Yes)
         ;;
       *)
         echo "Cancelled — database not changed."
         return 1
         ;;
     esac
    echo "Recreating database '$dbname'..."
    run_root_client -e "DROP DATABASE IF EXISTS $dbname; CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
     if [[ $? -eq 0 ]]; then
       echo "OK: Recreated database '$dbname'."
     else
       echo "ERROR: Failed to recreate database '$dbname'."
     fi
   }

  create_user() {
    read "username?Username: "
    read -s "password?Password: "
    echo
    run_root_client -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
  }

  update_database() {
    read "dbname?Database to update: "
    echo
    echo "WARNING: This will DROP the database if it exists, CREATE it anew, then import an SQL file."
    read "confirm?Proceed? (y/N): "
    case "$confirm" in
      y|Y|yes|YES|Yes)
        ;;
      *)
        echo "Cancelled — database not changed."
        return 1
        ;;
    esac
    read "filepath?SQL file path to import (leave blank to pick from $HOME/Downloads): "
    if [[ -z "$filepath" ]]; then
      # Ask whether to use latest file or pick via fzf from Downloads
      read "use_latest?Use latest file from Downloads? (Y/n): "
      case "$use_latest" in
        ''|Y|y|Yes|yes|YES)
          filepath=$(find "$HOME/Downloads" -maxdepth 1 -type f \( -iname '*.sql' -o -iname '*.sql.gz' -o -iname '*.gz' -o -iname '*.zip' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk '{ $1=""; sub(/^ /,""); print; exit }')
          ;;
        *)
          filepath=$(find "$HOME/Downloads" -maxdepth 1 -type f \( -iname '*.sql' -o -iname '*.sql.gz' -o -iname '*.gz' -o -iname '*.zip' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | cut -d' ' -f2- | fzf --height 20 --prompt "Pick file from Downloads: ")
          ;;
      esac
    fi

    if [[ -z "$filepath" || ! -f "$filepath" ]]; then
      echo "ERROR: File not found: $filepath"
      return 1
    fi
    echo "Recreating database '$dbname'..."
    run_root_client -e "DROP DATABASE IF EXISTS \`$dbname\`; CREATE DATABASE \`$dbname\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    if [[ $? -ne 0 ]]; then
      echo "ERROR: Failed to recreate database '$dbname'."
      return 1
    fi
    echo "Importing '$filepath' into '$dbname'..."
    case "$filepath" in
      *.gz)
        gunzip -c "$filepath" | run_root_client -D"$dbname"
        ;;
      *)
        run_root_client -D"$dbname" < "$filepath"
        ;;
    esac
    if [[ $? -eq 0 ]]; then
      echo "OK: Database updated and import complete."
    else
      echo "ERROR: Import failed."
    fi
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
    echo "OK: Saved credentials to $HOME/.my.cnf (permissions 600)"
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
      echo "OK: Exported to $outfile"
      UPDATE_DONE=1
      return 0
    else
      echo "ERROR: Export failed. Check permissions, credentials and query syntax."
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
      echo "OK: DROP executed (if the user existed)."
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
    read -k 1 -r "PAUSE?Press Enter to continue or q to quit..."
    echo
    if [[ "$PAUSE" == "q" || "$PAUSE" == "Q" ]]; then
      UPDATE_DONE=1
    fi
  }

  UPDATE_DONE=0
  while true; do
    local choice
    local plain_choice
    choice=$(printf "%s\n" "${menu[@]}" | fzf \
      --ansi \
      --height 20 \
      --prompt "MariaDB › " \
      --border)

    plain_choice=$(print -r -- "$choice" | sed $'s/\x1B\\[[0-9;]*[A-Za-z]//g')
    [[ -z "$plain_choice" || "$plain_choice" == "$quit_label" ]] && break
    run_command "${commands[$plain_choice]}"
    if [[ $UPDATE_DONE -eq 1 ]]; then
      break
    fi
  done
}
