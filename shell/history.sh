# shellcheck shell=bash
# Command history: keep more of it, and don't lose it when several terminals are open.

HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth      # skip duplicates and commands starting with a space
shopt -s histappend         # append to ~/.bash_history instead of overwriting it
shopt -s checkwinsize       # keep $LINES/$COLUMNS right after the window is resized
