#!/bin/zsh

# ===========================
# PostgreSQL Command Manager
# ===========================
# Works for any user.
# Priority for PostgreSQL user:
#   1. $PGUSER (if set)
#   2. current shell user ($USER)
#
# Optional env vars:
#   PGDATABASE (default: postgres)
#   PGHOST
#   PGPORT
#
# Example:
#   export PGUSER=postgres
#   export PGDATABASE=mydb
# ===========================

pgdb() {
  local PG_USER="${PGUSER:-$USER}"
  local PG_DB="${PGDATABASE:-postgres}"

  # PostgreSQL commands menu
  declare -A commands=(
    ["🌐 Show Network Interfaces"]="ip addr show"
    ["▶️ Start PostgreSQL"]="sudo systemctl start postgresql"
    ["⏹ Stop PostgreSQL"]="sudo systemctl stop postgresql"
    ["🔄 Restart PostgreSQL"]="sudo systemctl restart postgresql"
    ["📊 Check PostgreSQL Status"]="sudo systemctl status postgresql"
    ["📌 Enable PostgreSQL on Startup"]="sudo systemctl enable postgresql"
    ["📴 Disable PostgreSQL on Startup"]="sudo systemctl disable postgresql"
    ["🔐 Log into PostgreSQL"]="psql -U $PG_USER -d $PG_DB"
    ["🔓 Log into Specific Database"]="log_into_database"
    ["📋 List Databases"]="psql -U $PG_USER -c '\\l'"
    ["➕ Create New Database"]="create_database"
    ["🗑 Drop Database"]="drop_database"
    ["👤 Create New User"]="create_user"
    ["🔑 Change User Password"]="change_user_password"
    ["📂 List Tables in Database"]="list_tables"
    ["💾 Backup Database"]="backup_database"
    ["♻️ Restore Database"]="restore_database"
    ["🔍 Show Active Connections"]="psql -U $PG_USER -c 'SELECT * FROM pg_stat_activity;'"
    ["🚪 Quit"]=":"
  )

  # -------- Helper Functions --------

  create_database() {
    read "dbname?Enter new database name: "
    psql -U "$PG_USER" -c "CREATE DATABASE \"$dbname\";"
    echo "✅ Database '$dbname' created."
  }

  drop_database() {
    read "dbname?Enter database name to drop: "
    psql -U "$PG_USER" -c "DROP DATABASE \"$dbname\";"
    echo "❌ Database '$dbname' dropped."
  }

  create_user() {
    read "username?Enter new username: "
    read -s "password?Enter password: "
    echo
    psql -U "$PG_USER" -c "CREATE USER \"$username\" WITH PASSWORD '$password';"
    echo "✅ User '$username' created."
  }

  change_user_password() {
    read "username?Enter username: "
    read -s "password?Enter new password: "
    echo
    psql -U "$PG_USER" -c "ALTER USER \"$username\" WITH PASSWORD '$password';"
    echo "🔑 Password updated for '$username'."
  }

  list_tables() {
    read "dbname?Enter database name: "
    psql -U "$PG_USER" -d "$dbname" -c "\dt"
  }

  backup_database() {
    read "dbname?Enter database to backup: "
    read "filepath?Enter backup path (e.g. backup.dump): "
    pg_dump -U "$PG_USER" -d "$dbname" -F c -f "$filepath"
    echo "💾 Backup saved to '$filepath'."
  }

  restore_database() {
    read "filepath?Enter backup file path: "
    read "dbname?Restore into database name: "
    pg_restore -U "$PG_USER" -d "$dbname" -1 "$filepath"
    echo "♻️ Database restored."
  }

  log_into_database() {
    read "dbname?Enter database name: "
    psql -U "$PG_USER" -d "$dbname"
  }

  # -------- Menu Loop --------

  while true; do
    local choice
    choice=$(printf "%s\n" "${(@k)commands}" | \
      fzf --height 20 --prompt "🐘 PostgreSQL ($PG_USER) → " --border)

    [[ -z "$choice" || "$choice" == "🚪 Quit" ]] && break
    eval "${commands[$choice]}"
  done
}

