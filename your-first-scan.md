# Your First Scan

By the end of this chapter you will have
built the lab's practice repository,
scanned its whole history, and seen the
scanner find, in a nine-commit toy
project, five distinct planted secrets —
one of them reported twice, for a reason
chapter 5 explains. Everything after this
chapter is refinement; this is the core
move.

## Build the practice repository

Scanning a real repository first would
mix two lessons: learning the tool, and
being surprised by your own history. The
lab separates them. Its practice project,
**skywatch**, is a small weather fetcher
with a nine-commit history in which
secrets were planted on purpose — a cloud
key pair hardcoded during "prototyping",
an upstream API token, a token in a
release script, a private key committed
and then removed, and a dummy token in
the tests. Every value was invented for
this lab and labelled as invented where
it appears.

Build it with the script that ships with
this guide:

```bash
./gitleaks-lab/make-fixture.sh leaky-app
cd leaky-app
git log --oneline
```

```text
3cfdb46 Fix a capital in the README
289beab Add tests with a dummy token
ba9ef98 Document the key formats
13cdb9f Remove deploy key, use an agent instead
5d17172 Add deploy key for the demo server
89bef2a Remove hardcoded keys, use the environment
1e3086a Add upstream API client and release script
93db213 Hardcode cloud keys while prototyping
8342956 Initial commit: skywatch skeleton
```

The script fixes the author and the
commit dates, so the hashes come out
identical on every machine and the
guide's transcripts match yours exactly.
Read the history top to bottom and it
already tells the story: keys arrive,
keys are "removed", a deploy key arrives,
it is "removed" too, and HEAD is a
one-letter typo fix. As far as the
working tree is concerned, this project
is nearly clean. Histories disagree, and
that disagreement is the subject.

## Run the scan

```bash
gitleaks git .
```

The `.` is the repository to scan; you
can name a path from anywhere. By default
you also get a banner and coloured
output; the lab's transcripts add
`--no-banner --no-color`, which changes
nothing about the scan and makes output
that files and scripts can read. The
summary at the end is the verdict
(transcript
`gitleaks-lab/transcripts/t01-first-scan.txt`):

```text
4:49AM INF 8 commits scanned.
4:49AM INF scanned ~2890 bytes (2.89 KB) in 275ms
4:49AM WRN leaks found: 6
exit code: 1
```

Three things to take from three lines.
First, **the whole history was scanned** —
every commit's changes, all the way back
to the initial commit (the counter says
eight because one commit, the key
removal, adds nothing to scan; its
deletions carry no new text). Second, it
took a quarter of a second: scanning is
cheap, and "the repository is too big to
check" is almost never true. Third,
**the exit code is 1** — the machine-
readable way of saying *leaks were
found*. Remember it; chapter 8 builds
automation on it.

## See the findings

A summary tells you there is something to
look at. `--verbose` shows it:

```bash
gitleaks git --verbose .
```

Each finding prints as a small block:
the matched text, the rule that fired,
an entropy score, the file and line, and
the commit, author and date that brought
the secret in. The lab's six blocks are
in transcript t01; the roll of honour:

- A **cloud access key ID** in
  `config.py`, from commit `93db213`
  ("Hardcode cloud keys while
  prototyping") — the file that was
  deleted two commits later.
- A **generic API key** — the project's
  own `skw_live_` token — in
  `api_client.py`, commit `1e3086a`.
- A **GitHub personal access token** in
  `tools/release.sh`, the same commit.
- A **private key** in `deploy_key.pem`,
  commit `5d17172` — reported *twice*:
  once as written, and once because the
  detector decoded its base64 body and
  found the key again in the decoded
  text, under the tag `decoded:base64`.
  Same secret, same fingerprint; chapter
  5 pulls this apart.
- A second **generic API key** in
  `tests/test_api_client.py`, commit
  `289beab` — the tests' dummy token. The
  scanner cannot know it is a dummy. It
  has exactly the shape of the real
  thing, so it is reported exactly like
  the real thing. This is your first
  false positive, and chapter 9 deals
  with it properly.

And one planted secret is conspicuously
*absent*: the cloud **secret key** on the
line below the key ID in `config.py` was
never reported. The default rules catch
the ID half of that pair and have no
standalone rule for the secret half.
Verify it yourself: `git show
93db213:config.py` shows both lines; the
scan names only one. Keep that gap in
mind — chapter 13 returns to it, because
"the scanner found five" is not the same
sentence as "the history contains five".

Check: your first scan ends with `leaks
found: 6`, exit code 1, and the findings
match the five secrets above. If your
count differs, the likeliest cause is a
different Gitleaks version — the rules
travel with the version (chapter 3).
