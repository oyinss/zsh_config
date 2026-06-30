#!/bin/zsh

tmp() {
  local reset=$'\033[0m'
  local blue=$'\033[38;5;75m'
  local cyan=$'\033[38;5;80m'
  local green=$'\033[38;5;114m'
  local yellow=$'\033[38;5;221m'
  local purple=$'\033[38;5;141m'
  local red=$'\033[38;5;203m'
  local orange=$'\033[38;5;208m'

  clean_all() {
    local found
    found=$(find /tmp -maxdepth 1 -user "$USER" -name '*.so' -type f)
    if [[ -z "$found" ]]; then
      echo "${green}Nothing to clean.${reset}"
    else
      local count
      count=$(echo "$found" | wc -l)
      local size
      size=$(echo "$found" | du -ch | tail -1 | awk '{print $1}')
      echo "${yellow}Found ${count} files (${size}) to delete.${reset}"
      find /tmp -maxdepth 1 -user "$USER" -name '*.so' -type f -delete
      echo "${green}Cleaned.${reset}"
      df -h /tmp
    fi
  }

  clean_old() {
    local days="${1:-1}"
    local found
    found=$(find /tmp -maxdepth 1 -user "$USER" -name '*.so' -type f -mtime "+$days")
    if [[ -z "$found" ]]; then
      echo "${green}No .so files older than ${days} day(s).${reset}"
    else
      local count
      count=$(echo "$found" | wc -l)
      local size
      size=$(echo "$found" | du -ch | tail -1 | awk '{print $1}')
      echo "${yellow}${count} files (${size}) older than ${days} day(s).${reset}"
      find /tmp -maxdepth 1 -user "$USER" -name '*.so' -type f -mtime "+$days" -delete
      echo "${green}Cleaned.${reset}"
      df -h /tmp
    fi
  }

  run_check() {
    df -h /tmp
  }

  run_large() {
    du -sh /tmp/* /tmp/.*(N) 2>/dev/null | sort -rh | awk 'NR <= 15'
  }

  run_clean_old_interactive() {
    read "days?Delete files older than (days, default 1): "
    days=${days:-1}
    clean_old "$days"
  }

  if [[ $# -gt 0 ]]; then
    case "$1" in
      check|size|df)
        run_check
        return $?
        ;;
      clean|rm)
        clean_all
        return $?
        ;;
      old)
        local days="${2:-1}"
        clean_old "$days"
        return $?
        ;;
      large|largest)
        run_large
        return $?
        ;;
      *)
        echo "Usage: tmp [check|clean|old [days]|large]"
        return 1
        ;;
    esac
  fi

  local check_label="󰋦 Check /tmp Disk Usage"
  local clean_label="󰓫 Clean All Your .so Files"
  local old_label="󰑕 Clean .so Files Older Than N Days"
  local large_label="󰈙 Show Largest Files in /tmp"
  local quit_label="󰅙 Quit"

  local -a menu=(
    "${blue}󰋦${reset} ${purple}Check /tmp Disk Usage${reset}"
    "${yellow}󰓫${reset} ${purple}Clean All Your .so Files${reset}"
    "${orange}󰑕${reset} ${purple}Clean .so Files Older Than N Days${reset}"
    "${cyan}󰈙${reset} ${purple}Show Largest Files in /tmp${reset}"
    "${red}󰅙${reset} ${purple}Quit${reset}"
  )

  run_action() {
    local label="$1"
    echo
    case "$label" in
      "$check_label") run_check ;;
      "$clean_label") clean_all ;;
      "$old_label")   run_clean_old_interactive ;;
      "$large_label") run_large ;;
    esac
    echo
    read -k 1 -r "?${yellow}Press any key to continue or q to quit...${reset}"
    echo
    [[ "$REPLY" == "q" || "$REPLY" == "Q" ]] && return 1
    return 0
  }

  local quit=0
  while [[ $quit -eq 0 ]]; do
    local choice
    local plain_choice
    choice=$(printf "%s\n" "${menu[@]}" | fzf \
      --ansi \
      --height 12 \
      --prompt "/tmp › " \
      --border)

    plain_choice=$(print -r -- "$choice" | sed $'s/\x1B\\[[0-9;]*[A-Za-z]//g')
    [[ -z "$plain_choice" || "$plain_choice" == "$quit_label" ]] && break
    run_action "$plain_choice" || quit=1
  done
}
