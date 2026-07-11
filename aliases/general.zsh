#!/bin/zsh

# General aliases

alias c='clear'
alias ..='cd ..'
alias rmdir='rmdir -v'

# bat as cat
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# Open files with default X application
if [[ -x "$(command -v xdg-open)" ]]; then
    alias open='runfree xdg-open'
fi

# PDF reader
if [[ -x "$(command -v evince)" ]]; then
    alias pdf='runfree evince'
fi
