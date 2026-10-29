#!/usr/bin/env bats
# Tests for bin/extract — EXERCISE 1.

load helpers

setup() {
  skip "Exercise 1 — delete this line to start (see LEARNING.md)"
  setup_sandbox
  mkdir src && echo "hello" >src/greeting.txt
}

teardown() { teardown_sandbox; }

@test "extracts a .tar.gz" {
  tar -czf a.tar.gz -C src greeting.txt
  mkdir out && cd out
  run extract ../a.tar.gz
  [ "$status" -eq 0 ]
  [ "$output" = "extracted ../a.tar.gz" ]
  [ "$(cat greeting.txt)" = "hello" ]
}

@test "extracts a .tgz" {
  tar -czf a.tgz -C src greeting.txt
  mkdir out && cd out
  run extract ../a.tgz
  [ "$status" -eq 0 ]
  [ -f greeting.txt ]
}

@test "extracts a plain .tar" {
  tar -cf a.tar -C src greeting.txt
  mkdir out && cd out
  run extract ../a.tar
  [ "$status" -eq 0 ]
  [ -f greeting.txt ]
}

@test "extracts a .zip" {
  (cd src && zip -q ../a.zip greeting.txt)
  mkdir out && cd out
  run extract ../a.zip
  [ "$status" -eq 0 ]
  [ "$(cat greeting.txt)" = "hello" ]
}

@test "extracts a .gz and keeps the original" {
  cp src/greeting.txt . && gzip greeting.txt
  run extract greeting.txt.gz
  [ "$status" -eq 0 ]
  [ -f greeting.txt ] && [ -f greeting.txt.gz ]
}

@test "--help prints usage and exits 0" {
  run extract --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "no arguments: usage error, exit 2" {
  run extract
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage"* ]]
}

@test "missing file: exit 1" {
  run extract missing.zip
  [ "$status" -eq 1 ]
  [ "$output" = "extract: no such file: missing.zip" ]
}

@test "unsupported type: exit 2" {
  echo hi >notes.txt
  run extract notes.txt
  [ "$status" -eq 2 ]
  [ "$output" = "extract: unsupported file type: notes.txt" ]
}

@test "a file name with spaces works" {
  tar -czf "my archive.tar.gz" -C src greeting.txt
  mkdir out && cd out
  run extract "../my archive.tar.gz"
  [ "$status" -eq 0 ]
  [ -f greeting.txt ]
}
