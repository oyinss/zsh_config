#!/bin/zsh

# ███ █ █ ███   ███ █   ███ ███ ███ ███ ███
# █   █ █ █     █ █ █    █  █ █ █   █   █
#  █   █   █    █ █ █    █  █ █  █  ███  █
#   █  █    █   ███ █    █  ███   █ █     █
# ███  █  ███   █ █ ███ ███ █ █ ███ ███ ███

# Figlet Fonts
alias figfonts="showfigfonts"
alias s="subl"
alias cl="clear"
ip-show() {
  ip route get 1.1.1.1 | awk '{print $7}'
}

alias switch="sudo -i -u"
# Swappiness
alias swappiness="bat /proc/sys/vm/swappiness"
alias swappiness.10='echo "vm.swappiness=10" | sudo tee --append "/etc/sysctl.conf"'

# Timeshift
alias tsb="sudo timeshift --create --comments"
alias tsr="sudo timeshift --restore"

# Directory Management
alias mkdir="mkdir -p"
alias rf="rm -rf"
alias rm="rm -r"
alias cp="cp -r"

# File Listing (with eza)
alias list-row='eza -h --icons=auto'
alias list-all-row='eza -a --icons=auto --sort=name --group-directories-first'
alias list='eza -1 --icons=auto'
alias list-all='eza -a --icons=auto --sort=name --group-directories-first -1'
alias list-details='eza -lh --icons=auto'
alias list-all-details='eza -lha --icons=auto --sort=name --group-directories-first'
alias list-dir='eza -lhD --icons=auto'

# Process Management
alias listen.port="sudo lsof -i -P -n | grep LISTEN"
alias fpid="ps aux | grep -i"
alias kpid="kill -9"
nuke() {
  kill -9 $(ps aux | grep "[${1:0:1}]${1:1}" | awk '{print $2}')
}
# alias fpid="ps -ef | grep -i"

# File Searching
alias f="ls -a | fzf -i"
alias ff="ls -a | grep -Ei"
alias fff="find . -iname"

# NPM Related
alias npm.owner="ls -la $(npm root -g)"
alias npm.installed="npm list -g --depth=0"
alias npm.chown="sudo chown -R $USER $(npm root -g)"

# Local user Backup
alias backup="sudo $HOME/dotfiles/backup.sh"
alias ez="exec zsh"
alias zz='zi'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# easier to read disk
alias df='df -h'     # human-readable sizes
alias fs="du -sh" # Check Folder size
alias free='free -m' # show sizes in MB

# Session Management
alias logout="qdbus org.kde.KWin /Session org.kde.KWin.Session.quit"
alias q="exit"
alias hibernate="systemctl hibernate"
alias suspend="systemctl suspend"
# alias suspend="systemctl suspend -i"
alias suspend-i='sudo /bin/systemctl suspend -i'
# alias suspend='sudo /usr/bin/systemctl suspend -i'

# Magic Slack (Utility)
alias magic.slack="while sleep .1; do ps aux | grep slack | grep -v grep | grep magic; done"

# Crontab
alias setcron="sudo cp -r ~/dotfiles/var/spool/cron/* /var/spool/cron/"

# Log Grepping
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# SASS Watch
alias sass.watch="sass --watch scss:dist/css"

# Nethogs
alias netlog="sudo nethogs"

# Root User
alias root="sudo su"
