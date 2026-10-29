#!/usr/bin/env bats
# Tests for bin/clean-branches (worked example).

load helpers

# A realistic setup: a "GitHub" (bare repo) and your clone of it, with
#   merged   — merged into main with a normal merge
#   squashed — squash-merged: its remote branch was deleted, but Git can't see a merge
#   wip      — still in progress, has a remote branch: must be kept
setup() {
  setup_sandbox
  git init -q --bare -b main origin.git
  git clone -q origin.git clone 2>/dev/null
  cd clone || return
  git commit -q --allow-empty -m "initial commit"
  git push -q origin main
  git remote set-head origin main

  git switch -q -c merged && commit_file . merged.txt
  git switch -q main && git merge -q --no-ff merged -m "merge merged"

  git switch -q -c squashed && commit_file . squashed.txt
  git push -q -u origin squashed 2>/dev/null

  git switch -q -c wip main && commit_file . wip.txt
  git push -q -u origin wip 2>/dev/null

  git switch -q main
  git push -q origin main
  # "GitHub deletes the branch after the squash merge", then you fetch.
  git push -q origin --delete squashed 2>/dev/null
  git fetch -q --prune
}

teardown() { teardown_sandbox; }

branches() { git for-each-ref --format='%(refname:short)' refs/heads | sort | tr '\n' ' '; }

@test "deletes merged and squash-merged branches, keeps work in progress" {
  run clean-branches
  [ "$status" -eq 0 ]
  [[ "$output" == *"deleted merged (merged into main)"* ]]
  [[ "$output" == *"deleted squashed (remote branch deleted)"* ]]
  [ "$(branches)" = "main wip " ]
}

@test "--dry-run lists branches but deletes nothing" {
  run clean-branches --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"would delete merged"* ]]
  [ "$(branches)" = "main merged squashed wip " ]
}

@test "never deletes the branch you are on" {
  git switch -q merged
  run clean-branches
  [ "$status" -eq 0 ]
  [[ "$(branches)" == *"merged "* ]]
}

@test "says so when there is nothing to clean" {
  clean-branches >/dev/null
  run clean-branches
  [ "$output" = "nothing to clean" ]
}

@test "outside a git repository: exit 1 with a message" {
  cd "$SANDBOX"
  run clean-branches
  [ "$status" -eq 1 ]
  [[ "$output" == *"not inside a git repository"* ]]
}

@test "unknown option: exit 2" {
  run clean-branches --bogus
  [ "$status" -eq 2 ]
}
