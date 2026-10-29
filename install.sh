#!/usr/bin/env bash
# install.sh — WORKED EXAMPLE.
# Links every file under home/ into $HOME at the same relative path:
#   home/.bashrc   ->  ~/.bashrc
#   home/.gitconfig -> ~/.gitconfig
# Safe to run any number of times (idempotent): files already linked are skipped,
# and real files in the way are moved to ~/.dotfiles-backup/<timestamp>/ first.

# -e: stop on the first failing command.  -u: using an unset variable is an error.
# -o pipefail: a pipeline fails if ANY command in it fails, not just the last.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--dry-run] [--help]

Link the files in home/ into your home directory.

  -n, --dry-run   show what would happen without changing anything
  -h, --help      show this help
EOF
}

dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n | --dry-run) dry_run=true ;;
    -h | --help) usage; exit 0 ;;
    *) echo "install.sh: unknown option '$1'" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# The folder this script lives in, wherever it's run from.
dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Run a command, or only print it in dry-run mode.
run() {
  if "$dry_run"; then
    echo "would run: $*"
  else
    "$@"
  fi
}

linked=0
already=0
backed_up=0

# find -print0 + read -d '' handles file names containing spaces or newlines.
while IFS= read -r -d '' source; do
  relative="${source#"$dotfiles/home/"}"
  target="$HOME/$relative"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    already=$((already + 1))
    continue
  fi

  # -e is false for a broken symlink, so check -L too.
  if [[ -e "$target" || -L "$target" ]]; then
    run mkdir -p "$(dirname "$backup_dir/$relative")"
    run mv "$target" "$backup_dir/$relative"
    backed_up=$((backed_up + 1))
  fi

  run mkdir -p "$(dirname "$target")"
  run ln -s "$source" "$target"
  linked=$((linked + 1))
done < <(find "$dotfiles/home" -type f -print0 | sort -z)

echo "linked $linked, already linked $already, backed up $backed_up"

# Careful: `[[ $backed_up -gt 0 ]] && echo ...` as the LAST line would make the
# whole script exit with status 1 whenever nothing was backed up. Use `if`.
if [[ $backed_up -gt 0 ]] && ! "$dry_run"; then
  echo "originals moved to $backup_dir"
fi
