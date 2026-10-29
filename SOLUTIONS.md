# Reference solutions

> **This is the `solutions` branch. Never merge it into `main`.**
> It holds a reference answer for each exercise, with every test un-skipped.

Try the exercise first. Stuck for 30 minutes? Read only the comments in the reference, close it, and try again.

After your PR is green, compare:

```bash
git fetch origin
git diff origin/main origin/solutions -- bin/extract
```

| # | Script | Key idea |
| --- | --- | --- |
| 1 | `bin/extract` | Put `*.tar.gz` before `*.gz` in the `case`; exit 2 for "called wrong", 1 for "failed" |
| 2 | `bin/new-exercise` | Validate arguments before touching git; `git status --porcelain` is empty when clean |
| 3 | `bin/pr-ready` | Run each command inside `if`, so a failure is reported instead of `set -e` ending the script silently |

A different solution isn't a wrong one — if your version passes the tests and ShellCheck, it's correct.
