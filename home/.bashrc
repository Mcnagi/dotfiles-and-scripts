# shellcheck shell=bash
# ~/.bashrc — read by every interactive Bash shell.
# Kept deliberately short: the real settings live in $DOTFILES/shell/*.sh.

# Non-interactive shells (scp, cron, scripts) must not run any of this.
[[ $- != *i* ]] && return

# This file is a symlink into the repo; follow it to find the repo itself.
DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
export DOTFILES

# Make everything in bin/ a command. The case guard stops PATH growing
# every time you run `source ~/.bashrc`.
case ":$PATH:" in
  *":$DOTFILES/bin:"*) ;;
  *) PATH="$DOTFILES/bin:$PATH" ;;
esac
export PATH

for file in "$DOTFILES"/shell/*.sh; do
  # shellcheck source=/dev/null
  source "$file"
done
unset file

# Machine-specific or private settings (work proxies, tokens, extra PATHs).
# This file is never committed — see README.
if [[ -f ~/.bashrc.local ]]; then
  # shellcheck source=/dev/null
  source ~/.bashrc.local
fi
