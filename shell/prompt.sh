# shellcheck shell=bash
# Prompt: user@host, current folder, and the git branch when inside a repo.
#   j@laptop ~/algorithms-in-csharp (practice) $

# Prints " (branch)" inside a git repo, nothing outside one.
# Detached HEAD (e.g. during a rebase) shows the short commit hash instead.
__prompt_git_branch() {
  local branch
  branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    git rev-parse --short HEAD 2>/dev/null)" || return 0
  printf ' (%s)' "$branch"
}

# \[ \] wrap colour codes so Bash knows they take no width; without them,
# long commands wrap onto the wrong line.
__green='\[\e[32m\]' __blue='\[\e[34m\]' __yellow='\[\e[33m\]' __reset='\[\e[0m\]'
PS1="${__green}\u@\h${__reset} ${__blue}\w${__reset}${__yellow}\$(__prompt_git_branch)${__reset} \$ "
unset __green __blue __yellow __reset
