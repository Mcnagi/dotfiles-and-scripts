#!/usr/bin/env bats
# Tests for bin/new-exercise — EXERCISE 2.

load helpers

setup() {
  setup_sandbox
  make_repo repo
  cd repo || return
}

teardown() { teardown_sandbox; }

current_branch() { git branch --show-current; }

@test "creates and switches to exercise/NUMBER-SLUG" {
  run new-exercise 7 merge-sort
  [ "$status" -eq 0 ]
  [ "$output" = "switched to exercise/7-merge-sort" ]
  [ "$(current_branch)" = "exercise/7-merge-sort" ]
}

@test "branches from the base branch even when you're on another branch" {
  git switch -q -c other && commit_file . other.txt
  run new-exercise 8 quick-sort
  [ "$status" -eq 0 ]
  [ "$(git rev-parse HEAD)" = "$(git rev-parse main)" ]
}

@test "uses the remote's default branch as the base when there is one" {
  git branch -q -m main practice
  git init -q --bare -b practice "$SANDBOX/origin.git"
  git remote add origin "$SANDBOX/origin.git"
  git push -q origin practice 2>/dev/null
  git remote set-head origin practice
  git switch -q -c other && commit_file . other.txt
  run new-exercise 9 min-heap
  [ "$status" -eq 0 ]
  [ "$(git rev-parse HEAD)" = "$(git rev-parse practice)" ]
}

@test "--help prints usage and exits 0" {
  run new-exercise --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "wrong number of arguments: exit 2" {
  run new-exercise 7
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage"* ]]
}

@test "NUMBER must be digits: exit 2" {
  run new-exercise 7a merge-sort
  [ "$status" -eq 2 ]
  [ "$output" = "new-exercise: NUMBER must be digits: 7a" ]
}

@test "SLUG must be lowercase-kebab: exit 2" {
  run new-exercise 7 Merge_Sort
  [ "$status" -eq 2 ]
  [ "$output" = "new-exercise: SLUG must be lowercase-kebab: Merge_Sort" ]
}

@test "refuses to run with uncommitted changes: exit 1" {
  echo change >dirty.txt
  run new-exercise 7 merge-sort
  [ "$status" -eq 1 ]
  [ "$output" = "new-exercise: commit or stash your changes first" ]
  [ "$(current_branch)" = "main" ]
}

@test "refuses when the branch already exists: exit 1" {
  git branch exercise/7-merge-sort
  run new-exercise 7 merge-sort
  [ "$status" -eq 1 ]
  [ "$output" = "new-exercise: branch exercise/7-merge-sort already exists" ]
}

@test "outside a git repository: exit 1" {
  cd "$SANDBOX"
  run new-exercise 7 merge-sort
  [ "$status" -eq 1 ]
  [ "$output" = "new-exercise: not inside a git repository" ]
}
