# The Moving Parts

By the end of this chapter you will know
which part of Gitleaks does what, so that
when a scan surprises you — a finding you
did not expect, or an expected one that
never appears — you can name the part
responsible. There are not many parts: a
**detector** with a book of **rules**, fed
by three commands, producing **findings**
that become **reports**, all steerable by
one **config file** and one **ignore
file**.

## The three commands

- **`gitleaks git [repo]`** scans a git
  repository: every commit's changes, in
  order, with each finding attributed to
  the commit, author and date that
  introduced it. This is the command the
  guide is mostly about. Flags worth
  knowing early: `--log-opts` limits which
  commits are scanned (chapter 8), and
  `--pre-commit --staged` scans what is
  about to be committed instead of what
  already was (chapter 10).
- **`gitleaks dir [path]`** scans files
  and folders as they are right now, with
  no history attached. It answers "is
  anything secret sitting in this folder
  today?" — the state of a directory you
  were handed, a backup, a download
  (chapter 7).
- **`gitleaks stdin`** scans whatever is
  piped to it. Small, but it makes the
  detector composable: any text any tool
  can produce can be checked (chapter 7).

One engine sits behind all three. A
string that fools one command fools them
all, and a string caught by one is caught
by all — the difference between the
commands is only *which text* reaches the
detector and *what context* (commit,
author, date) the findings carry.

## The detector and the rules

The detector reads text looking for
secrets. For most rules the recognition
is a **regular expression** — a pattern
describing the shape of a known kind of
secret. A cloud access key ID has a fixed
prefix and length. A GitHub token starts
with `ghp_`. A private key announces
itself with a `-----BEGIN ... PRIVATE
KEY-----` header that no honest file
wears by accident.

Shape alone is not enough, because plenty
of innocent strings have secret-like
shapes: order numbers, checksums, the
identifiers in test data. So most rules
also weigh **entropy** — a measure of how
unpredictable a string looks. Real keys
are generated to be unpredictable, so
they score high; human-typed lookalikes
and repeated padding score low and are
let pass. When the lab's first fixture
draft gave its fake GitHub token the
value `ghp_` followed by the word "fake"
repeated, the scanner ignored it — a
word repeated is the opposite of
unpredictable, and the rule asks for the
shape *and* the randomness. The fixture's
tokens are random-looking because real
ones are.

Alongside the specific rules sits the
**generic rule**, a net rather than a
spear: a string assigned to a variable
whose name smells of secrets (`token`,
`api_key`, `secret`, `password`) and whose
value has enough entropy is reported as a
*generic-api-key*. It catches keys for
services nobody wrote a specific rule
for — including, in this guide's lab, the
practice project's own invented token
format.

The detector has one more sense worth
knowing about: it **decodes**. Text that
looks like base64 is decoded and scanned
again, several layers deep, because
secrets are often hidden — or merely
stored — encoded. The lab saw this
directly: its planted private key has a
base64 body, and the key was reported
twice, once as written and once for the
decoded text, tagged `decoded:base64`
(chapter 5). Hiding a secret inside an
encoding is not hiding it from this
scanner.

## Findings and fingerprints

Every match is a **finding**: the rule
that fired, the file, the line, the
secret itself, an entropy score, and —
for `git` scans — the commit hash,
author, email, date and commit message.
Chapter 5 takes one apart field by field.

Each finding also carries a
**fingerprint**, a single line that names
it exactly:

```text
commit-hash:file:rule:line
```

Fingerprints are how you talk about one
specific finding without pasting the
secret: the ignore file (chapter 9) and
the baseline (chapter 9) both work in
fingerprints. Two findings can share one
fingerprint — the decoded private key
above does — when they are the same
secret seen two ways; anything keyed by
fingerprint treats them as one.

## Reports and exit codes

A scan ends in a summary line and an
**exit code**: 0 when nothing was found,
1 when leaks were found (the value is
changeable with `--exit-code`). The exit
code is the part scripts and CI systems
read; the human parts are the **verbose**
listing on screen and the **report
files** — JSON, CSV, JUnit and SARIF —
written with `--report-format` and
`--report-path` (chapter 8). Reports
contain the secrets themselves in clear
text, which makes a report file a
sensitive object in its own right;
`--redact` exists for output you intend
to show anyone (chapter 5).

## The config and ignore files

Two optional files steer the scanner:

- **`.gitleaks.toml`**, the config. It can
  add rules of your own (the lab adds one
  for its project's token format in
  chapter 9), extend rather than replace
  the built-in rules, and **allowlist**
  paths, patterns and stopwords that
  should never be reported.
- **`.gitleaksignore`**, the ignore file.
  One fingerprint per line. It says "this
  exact finding, in this exact commit, is
  known and accepted" — the tool for
  individual false alarms, as opposed to
  the config's broader strokes.

Both are ways of teaching the tool about
your project. Neither deletes anything;
they change what gets reported, which is
why chapter 9 treats them as decisions to
make deliberately, one finding at a time.

## What it costs to run

Nothing about a scan leaves your machine:
no account, no service, no telemetry in
the tool itself. The whole detector is
one static program (chapter 3), fast
enough that the lab's practice repository
scans in a quarter of a second and large
real histories are measured in seconds or
minutes, not hours. The expensive part of
secret hygiene was never the scanning. It
is what you do about the findings —
which is why chapters 6 and 11 exist.
