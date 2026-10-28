# Gitleaks for Mere Mortals

A program works because it holds a
secret: a key for the API, a password
for the database, a token for the
deploy. Sooner or later, in almost
every project's life, one of those
secrets gets written into the code and
committed — and git, which forgets
nothing, keeps it in the history long
after the file is deleted and the team
has moved on. **Gitleaks** is the
scanner that reads the whole history
looking for exactly that: passwords,
API keys, access tokens and private
keys, each reported with the commit
that brought it in.

This guide explains how the scanner
recognises a secret, how to run it
over a repository's history, a plain
folder, or a pipe of text, how to read
what it reports down to the last
field, and how to tune it — silencing
the findings that are known and
innocent, teaching it your own
project's token formats, baselining a
repository you are adopting dirty.
It also covers catching the next
secret at the door, with a hook that
refuses the commit, and what to do on
the day a finding is real. The limits
are stated plainly, including the big
ones: deleting a secret does not
unpublish it, and a clean scan is not
proof that nothing is there.

The rules that govern everything here
are stated in chapter 1 and repeated
where they bite: **scan only
repositories that are yours — your
machines, or explicit permission —
and treat every secret you find as
compromised: rotate it, don't just
delete it.** The lab obeyed both
strictly. Its repository was invented
for the purpose, and every secret in
it was made up on the spot.

The lab behind this guide ran the real
thing: **Gitleaks 8.30.1**, installed
from the project's official release
tarball after its SHA-256 was checked
against the published checksums,
against a practice repository the lab
built for the purpose — a nine-commit
weather project with five planted,
invented secrets in its history.
Against it the lab scanned the full
history and read the findings field by
field from a JSON report, redacted a
scan for sharing, proved with plain
git that the deleted credentials file
is still readable in its commit,
scanned folders and piped text, aimed
scans at single commits and ranges and
checked the exit codes, silenced a
known false positive by fingerprint,
added a rule for the project's own
token format, built a baseline and
watched it catch a new secret, wrote a
SARIF report for code-scanning
platforms, and installed a pre-commit
hook that refused a bad commit in the
act. Along the way it verified three
things the guide relies on: the
default rules catch a cloud key ID but
not the secret half beneath it; the
provider's own documentation example
key is quietly ignored; and a base64
private key is found twice — once as
written, once decoded.

What the lab could not do, it did not
fake. It had no hosted CI and no real
services, so the GitHub Action, the
pre-commit framework, the other
install routes, and the neighbours
that verify secrets against live
services are taught from the projects'
documentation and labelled as such
wherever they appear. Rewriting
history to remove a secret is likewise
described, not performed — the guide
is firm that rotation comes first and
rewriting, if at all, second.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What Gitleaks is**](what-gitleaks-is.md) —
  the mental model: secrets live in
  history, not just in files, and the
  two rules that govern scanning
- [**The moving parts**](the-moving-parts.md) —
  the three commands, the detector and
  its rules, entropy, decoding,
  findings and fingerprints, the
  config and ignore files
- [**Installing Gitleaks**](installing-gitleaks.md) —
  the release download, verifying the
  checksum before you trust the tool,
  and the other routes, labelled
- [**Your first scan**](your-first-scan.md) —
  building the practice repository and
  finding its five planted secrets in
  the whole history
- [**Reading findings**](reading-findings.md) —
  one finding taken apart field by
  field, the JSON report, redaction,
  and the duplicate that isn't
- [**History is forever**](history-is-forever.md) —
  the deleted file that is still
  readable, who holds copies, and why
  rotation — not deletion, not
  rewriting — is the fix
- [**Scanning folders and text**](scanning-folders-and-text.md) —
  `gitleaks dir` for folders and
  working trees, `gitleaks stdin` for
  anything piped, and which question
  each answers
- [**Reports and exit codes**](reports-and-exit-codes.md) —
  the exit-code contract, aiming scans
  with `--log-opts`, and JSON, SARIF
  and the other report formats
- [**Tuning the noise**](tuning-the-noise.md) —
  `.gitleaksignore` fingerprints, a
  rule of your own in `.gitleaks.toml`,
  allowlists, and the baseline
- [**Catching it early**](catching-it-early.md) —
  the pre-commit hook that refuses a
  bad commit (run for real), CI as the
  second wall, the host's push
  protection as the third
- [**When you find a real one**](when-you-find-a-real-one.md) —
  the response, in order: facts,
  rotation, looking for use, cleanup,
  closing the door
- [**The neighbours**](the-neighbours.md) —
  TruffleHog and live verification,
  detect-secrets, git-secrets, and
  the hosts' own scanners
- [**Limits**](limits.md) — the secret
  half nobody catches, human
  passwords, split and encoded keys,
  false alarms, and what a clean scan
  actually means
- [**Troubleshooting**](troubleshooting.md) —
  the config that silently blinds the
  scanner, the shallow clone, the
  hook that doesn't fire, and the
  traps this guide's lab fell into so
  you don't have to
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Scanning repositories you do not own
or have no permission to inspect —
that is not a harder chapter of this
book, and chapter 1 explains the line.
Testing or using a secret you find in
anyone's history, including your own
organisation's beyond your remit.
Rewriting history as a hands-on
procedure (named and weighed in
chapter 6, deliberately not taught as
a recipe), and building a secrets
vault or a full incident-response
programme — chapter 11 is the
honest minimum for one person and
their own projects, and says when to
bring in help.

## How to use this guide

Read chapter 1 for the model and the
rules, and chapter 2 before scanning
anything real — knowing which part
holds what turns later surprises into
named problems. Build the practice
repository in chapter 4 and scan it
before you point the tool at a real
history; the fixture's five secrets
are the vocabulary the rest of the
guide speaks in. Chapter 6 is not the
optional chapter: understand why
deletion is not a fix before you are
tempted to call it one. Chapter 9
repays slowness — every suppression
is a decision, and the chapter treats
them that way. The lab's fixture
script and hook live in
`gitleaks-lab/`; its transcripts are
`gitleaks-lab/transcripts/`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Git for Mere Mortals](https://paulsullivan33-dev.github.io/git-for-mere-mortals/)
- [Cybersecurity for Mere Mortals](https://paulsullivan33-dev.github.io/cybersecurity-for-mere-mortals/)
- [age for Mere Mortals](https://paulsullivan33-dev.github.io/age-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/gitleaks-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/gitleaks-for-mere-mortals/blob/main/LICENSE-CODE).
