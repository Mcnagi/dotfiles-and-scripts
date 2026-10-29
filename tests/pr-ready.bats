#!/usr/bin/env bats
# Tests for bin/pr-ready — EXERCISE 3.
# `dotnet` is replaced by a stub that records each call in $SANDBOX/calls and fails
# when its first argument matches $FAIL_STEP. No .NET install needed.

load helpers

setup() {
  setup_sandbox
  stub_command dotnet 'echo "$*" >>"$SANDBOX/calls"; [[ "$1" != "${FAIL_STEP:-none}" ]]'
  export SANDBOX
}

teardown() { teardown_sandbox; }

calls() { cat "$SANDBOX/calls" 2>/dev/null; }

@test "runs format, build, test in order and says ready to push" {
  run pr-ready
  [ "$status" -eq 0 ]
  [[ "$output" == *"✔ format"*"✔ build"*"✔ test"*"ready to push"* ]]
  [ "$(calls)" = "$(printf '%s\n' 'format --verify-no-changes' 'build --nologo' 'test --nologo --no-build')" ]
}

@test "stops at the first failure and does not run later steps" {
  FAIL_STEP=build run pr-ready
  [ "$status" -eq 1 ]
  [[ "$output" == *"✘ build"* ]]
  [[ "$output" == *"pr-ready: build failed"* ]]
  [[ "$(calls)" != *"test"* ]]
}

@test "a format failure stops before building" {
  FAIL_STEP=format run pr-ready
  [ "$status" -eq 1 ]
  [[ "$output" == *"pr-ready: format failed"* ]]
  [ "$(calls)" = "format --verify-no-changes" ]
}

@test "--skip-format skips the format step" {
  run pr-ready --skip-format
  [ "$status" -eq 0 ]
  [[ "$(calls)" != *"format"* ]]
}

@test "--help prints usage and exits 0" {
  run pr-ready --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "unknown option: exit 2" {
  run pr-ready --bogus
  [ "$status" -eq 2 ]
}

@test "dotnet missing from PATH: exit 1 with a clear message" {
  # A PATH holding only bash, so a real dotnet in /usr/bin can't be found either.
  mkdir "$SANDBOX/only-bash"
  ln -s "$(command -v bash)" "$SANDBOX/only-bash/bash"
  PATH="$REPO_ROOT/bin:$SANDBOX/only-bash" run pr-ready
  [ "$status" -eq 1 ]
  [ "$output" = "pr-ready: dotnet not found on PATH" ]
}
