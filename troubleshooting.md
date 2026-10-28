# Troubleshooting

By the end of this chapter the failures
this guide's lab actually met — and the
ones the tool's design predicts — will
each have a name, a test, and a fix. They
are ordered the way they usually arrive:
first the scan that finds too little,
then the one that finds too much.

## "It found nothing, and I don't believe it"

**Your config replaced the rule book.**
A `.gitleaks.toml` without `[extend]
useDefault = true` discards every
built-in rule and keeps only yours. The
scan runs beautifully and finds almost
nothing, forever. Test: move the config
aside and scan again. Fix: chapter 9's
extend block. This is the most dangerous
failure in the chapter because it is
silent and confident.

**You scanned less history than you
think.** "8 commits scanned" in the
summary is the truth about what was
examined — compare it with `git log
--oneline | wc -l`. A shallow clone
(CI systems love `--depth 1`) shows the
scanner only the tip; a narrow
`--log-opts` range does the same on
purpose. Fix the fetch (`git fetch
--unshallow`) or widen the range, and
treat any report that does not state its
range as unfinished.

**The secret's shape is not in the
rules.** Chapter 13's whole catalogue:
the unpatterned half of a pair, the
human password, the brand-new format.
Test with chapter 7's stdin: pipe the
string itself to `gitleaks stdin`. If
the detector cannot see it alone in a
line, no scan arrangement will make it
see it in a repository. Your remedy is a
rule of your own (chapter 9), not a
louder scan.

**The string was too well-behaved.** The
lab's first fake GitHub token — the word
"fake" repeated after `ghp_` — matched
the shape and was declined on entropy.
Test data invented to *look* harmless
often fails the same way in reverse:
real secrets are random, so fixtures
must be too. If you are testing the
scanner, test it with strings shaped
like the truth.

## "It found too much"

**One secret, two findings.** The
private key's pair (chapter 5): one
sighting as written, one from the
decode pass, same fingerprint. Count and
triage by fingerprint and the phantom
crowd halves. This is the tool working
as designed.

**A wall of old findings on adoption
day.** Forty findings is not a scanning
problem; it is chapter 9's baseline,
followed by chapter 11's rotation
schedule. Suppressing them one by one in
`.gitleaksignore` also works and is
slower and more honest about each —
choose per finding count and per how
much you trust "known".

**The same dummy in forty test files.**
A class, not a sighting: that is the
config allowlist's job (paths, regexes),
not forty ignore lines. Chapter 9.

## "The hook doesn't fire"

- **Not executable.** `chmod +x
  .git/hooks/pre-commit`; git ignores
  hook files it cannot run, silently.
- **Not installed here.** Hooks live in
  `.git/hooks/`, per clone (chapter 10).
  A fresh clone has none, whatever the
  repository's README promises.
- **Installed, but gitleaks is not on
  the hook's PATH.** Hooks run with a
  minimal environment; a scanner in
  `~/bin` may vanish. Test by running the
  hook file directly from a terminal in
  the repository.
- **Bypassed.** `git commit --no-verify`
  skips hooks by design. If the commit
  landed despite the hook and the change
  contained a secret, the answer is in
  the command history, not the tooling —
  and the response is chapter 11, not a
  better hook.

## "The scan is slow" or "the report is enormous"

- **Slow:** the usual cause is a history
  with very large files — vendored
  binaries, committed archives, media.
  `--max-target-megabytes` skips files
  past a size; archives are not unpacked
  unless `--max-archive-depth` says so.
  On the lab's scale (a quarter-second)
  none of this arises; on a decade-old
  monorepo it is the difference between a
  minute and an hour.
- **Enormous:** reports are per-finding
  and findings multiply across history —
  the same secret in thirty commits is
  thirty records. For triage, group
  before you read: by rule
  (`jq -r '.[].RuleID'`), by file, or by
  secret itself, and let chapter 9's
  tuning shrink the next report.

## "The exit code says what I didn't want"

A pipeline that treats *any* non-zero
exit as "leaks" will also trip on
*errors* — a mistyped path fails the
scan with a different code and a plain
message. Read the message before
concluding anything from the number, and
remember `--exit-code` exists if your
tooling needs leaks to announce
themselves with a value of their own.
And the mirror failure: a scan wired
into CI with its output ignored is worse
than no scan, because it manufactures
confidence. The exit code is the
contract (chapter 8); something must
actually be listening to it.
