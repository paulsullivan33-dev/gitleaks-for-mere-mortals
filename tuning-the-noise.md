# Tuning the Noise

By the end of this chapter the fixture's
report will contain only findings that
deserve a human's attention: the known
false positive will be silenced by name,
the project's own token format will be
reported under the project's own rule,
and a repository mid-cleanup will have a
baseline that lets new leaks stand out
from old ones. Tuning is where a scanner
becomes usable — and where it can be
ruined, if the silencing is done lazily.

## First, be sure it is noise

Every suppression mechanism in this
chapter will happily hide a real secret.
So the rule of the chapter, before any
mechanism: **suppress a finding only
after you have looked at it and can say
what it is.** The fixture's candidate is
honest — the tests' dummy token, invented
for the lab, labelled in its own file as
a dummy. Its real-world cousins are test
fixtures, documentation examples, and
long-dead keys kept in test data. If you
cannot say a finding is one of those,
it is not noise; it is chapter 11.

## Silencing one finding: `.gitleaksignore`

The ignore file accepts **fingerprints**
(chapter 5) — one exact finding, in one
exact commit, at one exact line. Get the
dummy's fingerprint from the report and
write it into `.gitleaksignore` in the
repository's root (transcript
`gitleaks-lab/transcripts/t07-gitleaksignore.txt`):

```bash
jq -r '.[] | select(.File == "tests/test_api_client.py") | .Fingerprint' ../first-report.json
```

```text
289beab6242fc604ee6d09b4b2deac47de864159:tests/test_api_client.py:generic-api-key:10
```

```bash
cat > .gitleaksignore <<'EOF'
289beab6242fc604ee6d09b4b2deac47de864159:tests/test_api_client.py:generic-api-key:10
EOF
gitleaks git .
```

```text
4:49AM WRN leaks found: 5
exit code: 1
```

Six findings become five, and the scan
still fails — exactly right. The dummy is
silenced; the four remaining records
(the key seen twice, the tokens, the key
ID) are untouched. Note the precision of
what you just did: if that dummy token's
line is edited, or the same token is
committed somewhere else, the fingerprint
no longer matches and the finding comes
back. An ignore entry is a decision
about *one sighting*, not a blessing on
a string. Commit the `.gitleaksignore`
with the repository, so the decision is
reviewed like any other change — a
suppression nobody reviewed is a hiding
place, and chapter 13 says more about
that.

## Teaching it your own formats: `.gitleaks.toml`

Suppression is half of tuning. The other
half is *recognition*: your project has
its own token shapes, and a rule of your
own reports them under your own name,
with your own severity conversation
attached. The lab adds one for the
fixture's `skw_live_` format. In the
repository root, `.gitleaks.toml`:

```toml
title = "skywatch lab config"

[extend]
useDefault = true

[[rules]]
id = "skywatch-token"
description = "Skywatch upstream API token (project-specific format)"
regex = '''skw_live_[0-9a-f]{40}'''
keywords = ["skw_live_"]
```

The `[extend]` block is the important
part: `useDefault = true` says *keep all
the built-in rules and add mine*.
Without it, a config file **replaces**
the default rule book — the single most
common way people accidentally blind
their scanner, and chapter 14's first
troubleshooting entry. The rule itself
is three ideas: an `id` (what findings
will be labelled), a regular expression
(the shape), and `keywords` (cheap hints
that tell the detector where to look
closely).

Run against a fresh copy of the fixture
with this config in place (transcript
`gitleaks-lab/transcripts/t08-custom-rule.txt`),
the report's roll by rule becomes:

```text
$ jq -r '.[].RuleID' ../rules-report.json | sort | uniq -c
      1 aws-access-token
      1 github-pat
      2 private-key
      2 skywatch-token
```

Both `skw_live_` tokens — the client's
and the tests' dummy — are now reported
under `skywatch-token`, once each: when
two rules match the same secret, the
report carries it a single time, and
your rule takes the credit. The same
config file can carry **allowlists** —
paths never to scan, regexes never to
report, stopwords that mark a string as
known-innocent — for the broader strokes;
reach for those when a whole *class* of
matches is innocent (generated files,
vendored code), and for `.gitleaksignore`
when it is one specific sighting.

## Adopting mid-mess: the baseline

Real repositories are adopted dirty. Ten
years of history may hold forty findings,
and a team that cannot merge until all
forty are rotated will simply stop
running the scanner. The **baseline** is
the honest compromise: tell Gitleaks
"these findings are known; report only
what is new". A baseline is just a
report, accepted (transcript
`gitleaks-lab/transcripts/t09-baseline.txt`):

```bash
gitleaks git --report-format json --report-path ../baseline.json .
gitleaks git --baseline-path ../baseline.json .
```

```text
4:49AM INF no leaks found
exit code: 0
```

The same history that failed minutes ago
now passes — not because it is clean,
but because its dirt is *catalogued*.
And the catalogue is not a pardon: the
lab commits one new token and scans
again against the baseline:

```text
4:49AM INF 9 commits scanned.
4:49AM WRN leaks found: 1
exit code: 1
```

The new finding is caught, by its new
fingerprint, while its forty older
cousins stay silent. That is the deal a
baseline offers: history's debts are
written down and scheduled (chapter 11
is the schedule), and from today forward
the line is held. A baseline that is
never burned down is just an ignore file
with extra steps — regenerate it as
findings are rotated away, and let it
shrink to nothing.
