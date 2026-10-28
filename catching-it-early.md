# Catching It Early

By the end of this chapter a secret will
have been stopped at the exact moment it
tried to enter history — by a git hook
you installed, running a scan you can
watch work — and you will know where the
two other walls stand (continuous
integration, and your host's own push
protection) and which parts of this
chapter were run for real and which are
documented only.

## The cheapest moment

Every chapter so far has been about the
archaeology of failure. Flip the timeline
and the economics change completely: a
secret stopped *before* the commit costs
a minute of embarrassment. After the
commit it costs chapter 6's publication
and chapter 11's rotation. Hooks exist
to move the scan to the cheap moment.

Git itself provides the hook: a script
named `pre-commit` in `.git/hooks/` runs
before every commit, and if it exits
non-zero, the commit does not happen.
Gitleaks provides the scan shaped for
exactly that spot: `gitleaks git
--pre-commit --staged` examines the
**staged** changes — the diff about to
become a commit — and nothing else.

## The hook, run for real

The lab's hook ships with this guide as
`gitleaks-lab/pre-commit`:

```bash
#!/usr/bin/env bash
# Refuse to commit anything gitleaks flags in the staged changes.
exec gitleaks git --pre-commit --staged --no-banner --no-color
```

Install it into the fixture and try to
do something bad (transcript
`gitleaks-lab/transcripts/t11-pre-commit-hook.txt`):

```bash
cp ../gitleaks-lab/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo 'BACKUP_TOKEN = "skw_live_0123456789abcdef0123456789abcdef01234567"' >> skywatch.py
git add skywatch.py
git commit -m 'Add a backup token'
```

```text
4:49AM WRN leaks found: 1
exit code: 1
```

And the commit simply does not exist —
`git log` shows nothing new, because the
hook's exit code vetoed it. The author
unstages, deletes the line, and commits
their actual work seconds later; the
transcript shows a clean commit going
through immediately afterwards, the hook
scanning its 36 bytes and finding
nothing. That is the whole experience
when it works: one blocked commit, one
lesson, no incident.

Three honest caveats about hooks:

- **They are per-clone.** `.git/hooks/`
  is not part of the repository and does
  not travel with it. Every clone must
  install its own, which is why teams
  distribute hooks through a framework or
  a setup script — and why a hook alone
  is never the only wall.
- **They can be bypassed.** `git commit
  --no-verify` skips hooks entirely. A
  hook catches accidents; it is not a
  control against intent, and should
  never be described as one.
- **They only see the staged diff.** A
  secret committed before the hook was
  installed is invisible to it. Hooks
  guard the future; chapters 4 to 9 are
  still the tools for the past.

## The framework route (documented only)

The **pre-commit framework**
(pre-commit.com) manages hooks for many
tools from one `.pre-commit-config.yaml`,
and Gitleaks publishes an official hook
definition for it; a project adds a few
lines of YAML and every contributor's
environment gains the same check, pinned
to the same version. The lab did not run
the framework — the plain hook above is
the verified route — but for a team, the
framework is how the plain hook's
per-clone weakness is usually solved,
and the project's documentation carries
the exact snippet.

## The second wall: CI

What slips past a missing or bypassed
hook meets the exit code in continuous
integration (chapter 8): the pull request
is scanned over the range it adds, and a
finding fails the build. The project's
official **GitHub Action** wraps exactly
that, and equivalent steps for other CI
systems are the `--log-opts` range scan
in a shell step. Documented only here —
the lab has no hosted CI to run — but
built entirely from pieces chapters 4
and 8 verified locally.

CI has one weakness a hook does not:
by the time CI objects, *the secret has
been committed and pushed*. On a private
repository with a trustworthy team that
may be an acceptable place to catch it —
rotation is still the correct response,
but the exposure was small and known.
The hook's whole virtue is that it fires
before even that much publication
happens.

## The third wall: the host

GitHub and GitLab both offer **secret
scanning** on their servers, and GitHub's
**push protection** refuses pushes that
contain recognisable secrets at all —
the host itself running a scanner much
like this one, on the way in. These are
hosted features, documented only in this
guide (chapter 12 meets them again as
neighbours), and where they are
available they are worth turning on:
they watch every push, including the
ones from machines with no hook and no
local scanner installed.

The walls layer, and that is the design:
the hook for the author, CI for the
team, the host for the organisation —
and the history scan, run regularly,
for everything all three missed while
nobody was watching.
