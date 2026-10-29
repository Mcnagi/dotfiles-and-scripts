# Learning guide

Read the worked examples first — `install.sh` and `bin/clean-branches` — then do the exercises.
Each exercise has an issue, a spec at the top of its script, and tests that define "done".

## Workflow for each exercise

1. Create a branch: `git switch -c exercise/1-extract`
2. Open the test file (e.g. `tests/extract.bats`) and delete the `skip "Exercise …"` line in `setup()`.
3. Run `bats tests/extract.bats` and watch every test fail (red).
4. Implement the script until they pass (green), then tidy it (refactor).
5. Run `shellcheck bin/extract` and fix every warning — CI will.
6. Commit, push, open a PR with `Closes #<issue>`, merge when CI is green.

## Stages

| Stage | What | Where | Learn |
| --- | --- | --- | --- |
| 1 | Shell config | `home/.bashrc`, `shell/` | How Bash starts up, `PATH`, aliases vs functions, the prompt |
| 2 | Installer | `install.sh` *(worked example)* | Symlinks, `set -euo pipefail`, idempotency, `--dry-run` |
| 3 | Scripts | `bin/` | Arguments, exit codes, `case`, regex, stderr vs stdout |
| 4 | CI | `.github/workflows/ci.yml` | ShellCheck, bats, testing in a clean container |
| 5 | Tests | `tests/` | Sandboxes, stubbing commands, testing failure paths |

## Exercises

| # | Script | Practises | Read first |
| --- | --- | --- | --- |
| 1 | `bin/extract` | `case` patterns, exit codes, quoting file names | `install.sh` |
| 2 | `bin/new-exercise` | Input validation with regex, git plumbing | `bin/clean-branches` |
| 3 | `bin/pr-ready` | Running commands and handling failure; testing with a stubbed `dotnet` | `tests/helpers.bash` |

Stuck for 30 minutes? Run the script with `bash -x bin/extract file.zip` — `-x` prints every line as it runs.

Reference solutions are on the [`solutions`](../../tree/solutions) branch, which is never merged. Try first; compare after.

## Things Bash gets wrong by default

- **Quote every variable**: `"$file"`, not `$file`. Unquoted, `my archive.zip` becomes two arguments. ShellCheck catches this (SC2086).
- **`set -e` has gaps.** It doesn't stop on a failure inside `if`, `&&`, `||` or `!` — that's deliberate, and it's how you handle errors yourself. Exercise 3 depends on it.
- **`cmd && echo yes` as the last line** of a script makes the script exit 1 whenever `cmd` fails. Use `if`. (`install.sh` has a comment on this.)
- **A script can't change your shell's directory or variables** — it runs in a child process. That's why `mkcd` in `shell/aliases.sh` is a function.

## Stretch goals

Open your own issues for these:

- Run CI on **macOS** too. Its built-in Bash is 3.2 (2007): `declare -A` and `readlink -f` behave differently — find out what breaks.
- A `bootstrap.sh` that installs your tools (`git`, `gh`, .NET SDK) from a package list.
- `bin/dotfiles-doctor`: checks each link from `install.sh` is still in place and reports broken ones.
- Port the prompt to **zsh**, or try **starship**.
