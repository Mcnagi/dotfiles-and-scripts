# dotfiles-and-scripts

[![CI](https://github.com/Mcnagi/dotfiles-and-scripts/actions/workflows/ci.yml/badge.svg)](https://github.com/Mcnagi/dotfiles-and-scripts/actions/workflows/ci.yml)

My shell and Git setup, plus small scripts that automate my daily workflow.
One command sets up a new machine; every script is linted with ShellCheck and tested with bats.

## Install

```bash
git clone https://github.com/Mcnagi/dotfiles-and-scripts.git ~/dotfiles-and-scripts
~/dotfiles-and-scripts/install.sh --dry-run   # see what it will do
~/dotfiles-and-scripts/install.sh
```

`install.sh` symlinks each file in `home/` into your home folder. Anything already there is moved to `~/.dotfiles-backup/<timestamp>/` first, and running it again changes nothing.

Then add the two **private** files this repo deliberately doesn't contain:

```bash
# ~/.gitconfig.local — your identity. Use GitHub's no-reply address
# (Settings → Emails) if you don't want your real email in public commits.
[user]
    name = Your Name
    email = 12345678+you@users.noreply.github.com
```

```bash
# ~/.bashrc.local — anything machine-specific or secret.
export SOME_TOKEN=...   # never commit this
```

Open a new terminal to load everything.

## What's here

| Path | What it is |
| --- | --- |
| `home/.bashrc` | Loads everything in `shell/`, puts `bin/` on `PATH`, then `~/.bashrc.local` |
| `home/.gitconfig` | Rebase on pull, prune on fetch, handy aliases; includes `~/.gitconfig.local` |
| `shell/` | History settings, aliases, a prompt that shows the git branch |
| `install.sh` | The idempotent installer |
| `bin/clean-branches` | Deletes local branches that are merged, **including squash-merged** ones |
| `bin/extract` | Unpacks any common archive *(exercise 1)* |
| `bin/new-exercise` | Starts a correctly named branch for an issue *(exercise 2)* |
| `bin/pr-ready` | Runs format, build and test the way CI does *(exercise 3)* |
| `tests/` | bats tests for every script |

Every script supports `--help`.

## Develop

```bash
shellcheck install.sh bin/* home/.bashrc shell/*.sh   # lint
bats tests/                                           # test
```

On Windows, work inside **WSL** (Ubuntu). `.gitattributes` forces LF line endings, because a script saved with Windows (CRLF) line endings fails with `bad interpreter`. If Git on Windows loses a script's executable bit, restore it with `git update-index --chmod=+x bin/NAME`.

This repo is also a learning project — see [LEARNING.md](LEARNING.md).

## Licence

[MIT](LICENSE)
