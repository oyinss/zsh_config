#!/bin/zsh

gitm() {
  # Define an associative array with emoji-labeled Git commands
  declare -A commands=(
    ["🆕 Initialize New Git Repository"]="git init"
    ["📝 Create README.md"]="touch README.md"
    ["📥 Add All Files in Current Directory"]="git add ."
    ["📦 Add All Changes (Including Deletions)"]="git add --all"
    ["💬 Commit with Message"]="git_commit"
    ["✏️ Amend Last Commit Message"]="git_amend_commit"
    ["🌐 Add Remote Origin"]="git_remote_add"
    ["🌲 Set Default Branch to main"]="git branch -M main"
    ["🚀 Push Initial Commit to Origin main"]="git push -u origin main"
    ["💣 Force Push to Current Branch"]="git push -f"
    ["🔍 Check Git Status"]="git status -sb"
    ["🌿 List Git Branches"]="git branch"
    ["🔀 Rename Current Branch"]="git_rename_branch"
    ["📂 Checkout Branch"]="git_checkout"
    ["🌱 Create and Switch to New Branch"]="git_create_branch"
    ["📡 Fetch Remote Data"]="git fetch"
    ["🔀 Merge Current Branch with Remote"]="git merge"
    ["⬇️ Pull Changes from Remote"]="git pull"
    ["🧬 Rebase Branch"]="git_rebase"
    ["↩️ Revert Last Commit"]="git revert HEAD"
    ["🧹 Reset Staged Changes"]="git reset"
    ["⏪ Hard Reset to HEAD~1"]="git_reset_hard 1"
    ["⏪ Hard Reset to HEAD~2"]="git_reset_hard 2"
    ["⏪ Hard Reset to HEAD~3"]="git_reset_hard 3"
    ["🔄 Reset Local to Remote on Main"]="git_reset_local_to_remote_main"
    ["🔗 Check Remote URLs"]="git remote -v"
    ["📡 Set Fetch URL for Origin"]="git_set_fetch_url"
    ["📤 Set Push URL for Origin"]="git_set_push_url"
    ["📜 View Git Log"]="git log"
    ["🧽 Unstage Files"]="git rm --cached"
    ["⚡️ Enable Fast-Forward Merges"]="git config --global pull.ff true"
    ["🌍 Configure Global Git Ignore"]="git_configure_global_ignore"
    ["🗒 Edit .gitignore in Current Directory"]="edit_repo_gitignore"
    ["🔑 Update Git Credential/Access Token"]="git_update_credential"
    ["🛠 Edit Git Credentials File"]="edit_git_credentials"
    ["🚪 Quit"]=": # Quit the function"
  )

  # Helper functions

  git_commit() {
    local msg
    echo -n "Enter commit message: "
    read -r msg
    if [[ -z "$msg" ]]; then
      echo "Aborting commit due to empty message."
      return 1
    fi
    git commit -m "$msg"
  }

  git_amend_commit() {
    local msg
    echo -n "Enter new commit message: "
    read -r msg
    if [[ -z "$msg" ]]; then
      echo "Aborting amend due to empty message."
      return 1
    fi
    git commit --amend -m "$msg"
  }

  git_remote_add() {
    local remote_name remote_url
    echo -n "Enter remote name (e.g., origin): "
    read remote_name
    echo -n "Enter remote URL: "
    read remote_url
    git remote add "$remote_name" "$remote_url"
  }

  git_rename_branch() {
    local new_branch
    echo -n "Enter new branch name: "
    read new_branch
    git branch -m "$new_branch"
  }

  git_checkout() {
    local branch
    echo -n "Enter branch name to checkout: "
    read branch
    git checkout "$branch"
  }

  git_create_branch() {
    local branch
    echo -n "Enter new branch name: "
    read branch
    git checkout -b "$branch"
  }

  git_set_fetch_url() {
    local remote_name url
    echo -n "Enter remote name: "
    read remote_name
    echo -n "Enter new fetch URL: "
    read url
    git remote set-url "$remote_name" "$url"
  }

  git_set_push_url() {
    local remote_name url
    echo -n "Enter remote name: "
    read remote_name
    echo -n "Enter new push URL: "
    read url
    git remote set-url --push "$remote_name" "$url"
  }

  git_configure_global_ignore() {
    git config --global core.excludesfile ~/.gitignore_global
    echo "Global .gitignore is set to ~/.gitignore_global."
    if command -v nvim >/dev/null 2>&1; then
      nvim ~/.gitignore_global
    else
      vim ~/.gitignore_global
    fi
  }

  edit_repo_gitignore() {
    [[ -f .gitignore ]] || { echo "Creating new .gitignore..."; touch .gitignore; }
    if command -v nvim >/dev/null 2>&1; then
      nvim .gitignore
    else
      vim .gitignore
    fi
  }

  git_reset_hard() {
    local n=$1
    echo -n "Are you sure you want to hard reset to HEAD~$n? (y/n): "
    local ans
    read ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      git reset --hard "HEAD~$n"
    else
      echo "Reset cancelled."
    fi
  }

  git_reset_local_to_remote_main() {
    echo -n "Are you sure you want to reset local main to origin/main? This will discard local changes! (y/n): "
    local ans
    read ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      git fetch origin && git reset --hard origin/main && git clean -fd
    else
      echo "Reset cancelled."
    fi
  }

  git_update_credential() {
    echo -n "Enter GitHub username: "
    read -r username
    if [[ -z "$username" ]]; then
      echo "❌ Username is required. Aborting."
      return 1
    fi

    echo -n "Paste your GitHub token (e.g. ghp_abcd1234efgh5678ijkl90mnopqrstuvwx): "
    read -r token
    if [[ -z "$token" || ! "$token" =~ ^ghp_ ]]; then
      echo "❌ Invalid or empty token. Aborting."
      return 1
    fi

    local credential="https://$username:$token@github.com"
    local cred_file="$HOME/.git-credentials"

    touch "$cred_file"
    sed -i '/github\.com/d' "$cred_file"
    echo "$credential" >> "$cred_file"

    git config --global credential.helper store

    echo "✅ GitHub credential for '$username' saved to $cred_file."

    echo -n "Open $cred_file in nvim for review? (y/n): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      nvim "$cred_file"
    fi
  }

  edit_git_credentials() {
    local cred_file="$HOME/.git-credentials"
    [[ -f "$cred_file" ]] || { echo "No credentials file found. Creating..."; touch "$cred_file"; }
    nvim "$cred_file"
  }

  while true; do
    local choice
    choice=$(printf "%s\n" "${(@k)commands}" | fzf --height 20 --prompt "🔧 Select a Git Command: " --border)

    if [[ -z "$choice" || "$choice" == "🚪 Quit" ]]; then
      echo "👋 Exiting Git Command Manager."
      break
    fi

    eval "${commands[$choice]}"
    break
  done
}

