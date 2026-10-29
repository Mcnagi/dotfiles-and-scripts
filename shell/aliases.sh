# shellcheck shell=bash
# Aliases: short names for commands you type all the time.
# Rule of thumb: alias it once you've typed it in full ten times.

alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'

# Git (see also the [alias] section in ~/.gitconfig)
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'

# .NET
alias dt='dotnet test'
alias db='dotnet build'
alias dfmt='dotnet format'

# Make a directory and move into it. This must be a function, not a script in bin/:
# a script runs in a child process, so its `cd` can't change your shell's directory.
mkcd() {
  mkdir -p -- "$1" && cd -- "$1" || return
}
