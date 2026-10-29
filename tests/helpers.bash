# shellcheck shell=bash
# Shared test helpers. Every test runs in a throwaway sandbox with its own $HOME,
# so tests never touch your real dotfiles or git config.

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup_sandbox() {
  SANDBOX="$(mktemp -d)"
  export HOME="$SANDBOX/home"
  mkdir -p "$HOME"
  export PATH="$SANDBOX/stubs:$REPO_ROOT/bin:$PATH"
  mkdir -p "$SANDBOX/stubs"

  # Predictable git: no system config, a fixed identity, no colour or pager.
  export GIT_CONFIG_NOSYSTEM=1
  export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com
  export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com
  export GIT_PAGER=cat
  cd "$SANDBOX" || return
}

teardown_sandbox() {
  rm -rf "$SANDBOX"
}

# make_repo DIR — a git repo on branch main with one commit.
make_repo() {
  git init -q -b main "$1"
  git -C "$1" commit -q --allow-empty -m "initial commit"
}

# commit_file REPO FILE — add a file and commit it.
commit_file() {
  echo "$2" >"$1/$2"
  git -C "$1" add "$2"
  git -C "$1" commit -q -m "add $2"
}

# stub_command NAME SCRIPT — put a fake NAME first on PATH.
# The fake runs SCRIPT, so a test controls exactly what the "tool" does.
stub_command() {
  printf '#!/usr/bin/env bash\n%s\n' "$2" >"$SANDBOX/stubs/$1"
  chmod +x "$SANDBOX/stubs/$1"
}
