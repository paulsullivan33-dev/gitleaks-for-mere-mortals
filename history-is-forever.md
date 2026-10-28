# History Is Forever

By the end of this chapter the most
important fact in this guide will be
something you have proven with your own
hands: **deleting a secret from a project
does not remove it from the project's
history**, and everyone who has ever
cloned the repository holds a copy of the
"deleted" text. This is the chapter the
whole tool exists to teach.

## The proof, in three commands

The fixture's `config.py` — the file with
the cloud credentials — was deleted in
commit `89bef2a`, six commits ago. At
HEAD it does not exist. Neither does the
deploy key. Start there (transcript
`gitleaks-lab/transcripts/t04-history.txt`):

```bash
ls config.py deploy_key.pem
```

```text
ls: cannot access 'config.py': No such file or directory
ls: cannot access 'deploy_key.pem': No such file or directory
```

Clean. Now ask the history about the same
file:

```bash
git log --oneline --all -- config.py
git show 93db213d43f1d05905743ab429c59ecf8c91abe0:config.py
```

```text
89bef2a Remove hardcoded keys, use the environment
93db213 Hardcode cloud keys while prototyping

# Prototype settings. TODO: move these to the environment.
# Both values are invented samples planted for the scanning lab.
AWS_ACCESS_KEY_ID = "AKIAQ7XMP2K4RW6T5VZ3"
AWS_SECRET_ACCESS_KEY = "FakeSecret/Ab3dEf6hIjKlMnOpQrStUvWxYz012"
AWS_DEFAULT_REGION = "us-east-1"
```

There it is: the full file, both values,
readable by anyone, forever, with
nothing more exotic than `git show`. The
removal commit's own summary makes the
situation plainer still:

```text
 README.md | 2 ++
 config.py | 5 -----
 2 files changed, 2 insertions(+), 5 deletions(-)
```

A deletion in git is a *new commit* that
says "from now on, this file is gone". It
is not an erasure of the commits where
the file lived. The history is an
append-only story, and the deletion is
just the latest chapter of it.

## Why this is worse than it looks

Work through who holds the old commits:

- **Every clone.** Anyone who cloned the
  repository before the deletion — every
  teammate, every laptop, every CI
  runner, every backup — has the secret
  in their copy, and git gives them no
  reason to even notice.
- **Every fork and mirror.** On a hosting
  service, forks keep their own copies;
  deleting from yours does not reach into
  theirs.
- **The host's own storage.** Hosted git
  services keep commits reachable in ways
  that survive file deletion, sometimes
  even history rewriting: cached views,
  pull-request refs, archives.
- **Your own past tense.** The scanner's
  attribution cuts both ways: a finding
  tells you the date a secret entered the
  history, which is the earliest moment
  you must assume it was exposed.

This is why the guide's second rule
(chapter 1) says what it says. A secret
that has been committed is not *at risk
of* exposure. It has been published, to
an audience you cannot enumerate. The
only remediation that actually closes
the hole is to **rotate the secret**:
revoke the old key, issue a new one, and
let the committed text become a souvenir
— a string that used to open something
and no longer does.

## What about rewriting history?

Git can be made to forget. Tools such as
**git filter-repo** and the **BFG
Repo-Cleaner** walk the history and
produce a new one with a file or a string
scrubbed from every commit, and a
force-push replaces the old history on
the host. This guide names them and does
not run them, deliberately:

- They are **documented-only** here
  because a rewrite is a serious operation
  with its own failure modes, and it
  deserves its own careful session, not a
  coda to a scanning chapter.
- A rewrite **changes every commit hash
  after the change**, so every clone must
  be re-made and every open branch
  reconciled. On a shared repository it
  is a team event, not a quiet fix.
- Most importantly, a rewrite **does not
  unpublish anything**. It stops *future*
  readers of *your copy* from finding the
  secret. The clones, forks and caches
  above are untouched. Rewriting without
  rotating is tidying the scene of the
  leak while the key still works.

The honest order of operations is the
one chapter 11 lays out: rotate first,
then — if the repository's circumstances
justify the disruption — rewrite, notify
everyone who holds a clone, and treat
the episode as the incident it was.

## What the scanner is for, then

If deletion does not fix a leak and
rewriting does not unpublish it, what did
the scan buy you? The three things
remediation actually runs on:

- **A list.** Which secrets, of which
  kinds, in which files — the raw material
  of a rotation checklist.
- **A timeline.** The commit and date of
  each, so you know the exposure window
  and can ask what those keys could reach
  during it.
- **A stopping rule.** When the list is
  rotated and a fresh scan's only news is
  old, dead strings, the incident can be
  declared over on evidence rather than
  on hope.

The fixture's secrets are invented, so
its story ends with the proof above.
Yours, when it happens, continues in
chapter 11. And the way to have fewer
such stories is chapter 10's: catch the
secret on its way in, before history —
which is forever — gets a copy.
