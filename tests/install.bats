#!/usr/bin/env bats
# Tests for install.sh and home/.bashrc (worked examples).

load helpers

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "links every file in home/ into \$HOME" {
  run "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [ "$(readlink "$HOME/.bashrc")" = "$REPO_ROOT/home/.bashrc" ]
  [ "$(readlink "$HOME/.gitconfig")" = "$REPO_ROOT/home/.gitconfig" ]
}

@test "running twice changes nothing the second time (idempotent)" {
  "$REPO_ROOT/install.sh" >/dev/null
  run "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == "linked 0, already linked 2, backed up 0" ]]
}

@test "moves an existing real file to a backup instead of overwriting it" {
  echo "my old bashrc" >"$HOME/.bashrc"
  run "$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"backed up 1"* ]]
  [ -L "$HOME/.bashrc" ]
  backup="$(find "$HOME/.dotfiles-backup" -name .bashrc)"
  [ "$(cat "$backup")" = "my old bashrc" ]
}

@test "--dry-run changes nothing" {
  run "$REPO_ROOT/install.sh" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would run: ln -s"* ]]
  [ ! -e "$HOME/.bashrc" ]
}

@test "an unknown option is a usage error (exit 2)" {
  run "$REPO_ROOT/install.sh" --bogus
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown option '--bogus'"* ]]
}

@test ".bashrc sets DOTFILES and loads the aliases" {
  "$REPO_ROOT/install.sh" >/dev/null
  # -i makes the shell interactive, which is what makes it read ~/.bashrc.
  run env PATH=/usr/bin:/bin bash -i -c 'echo "dotfiles=$DOTFILES"; type -t ll' 2>/dev/null
  [[ "$output" == *"dotfiles=$REPO_ROOT"* ]]
  [[ "$output" == *"alias"* ]]
}

@test ".bashrc adds bin/ to PATH exactly once, even when sourced again" {
  "$REPO_ROOT/install.sh" >/dev/null
  # Start from a PATH without bin/, so this test can actually fail.
  run env PATH=/usr/bin:/bin bash -i -c 'source ~/.bashrc; source ~/.bashrc; echo "$PATH"' 2>/dev/null
  path_line="${lines[${#lines[@]} - 1]}"
  [ "$(tr ':' '\n' <<<"$path_line" | grep -cx "$REPO_ROOT/bin")" -eq 1 ]
}

@test ".bashrc loads ~/.bashrc.local when it exists" {
  "$REPO_ROOT/install.sh" >/dev/null
  echo 'export FROM_LOCAL=yes' >"$HOME/.bashrc.local"
  run bash -i -c 'echo "local=$FROM_LOCAL"' 2>/dev/null
  [[ "$output" == *"local=yes"* ]]
}
