# Reports and Exit Codes

By the end of this chapter a scan will be
something your scripts can act on, not
just something you read: reports in the
formats other tools consume, an exit
code that tells the truth, and scans
aimed at exactly the commits a situation
calls for — a pull request, a release, a
single suspect commit.

## The exit code is the interface

Everything in this chapter rests on one
small contract from chapter 4:

- **Exit code 0** — the scan completed
  and found nothing.
- **Exit code 1** — the scan completed
  and found leaks.

(Other non-zero values mean the scan
itself failed — a bad path, a broken
config — and the message on screen says
which. `--exit-code` can change the leaks
value if your tooling needs something
more distinctive.) Shells and CI systems
understand this contract natively, which
is why the lab's transcripts print it
after every scan. A step in a pipeline
that runs Gitleaks needs no parsing, no
log scraping: the command succeeds or
the build stops.

## Aiming the scan: `--log-opts`

A full history scan is the audit tool.
Day to day, the question is usually
narrower: *what does this change add?*
`--log-opts` passes options straight to
`git log`, and the scan covers exactly
the commits that selection names
(transcript
`gitleaks-lab/transcripts/t06-ranges-and-exit-codes.txt`):

```bash
gitleaks git --log-opts="HEAD~1..HEAD" .
```

```text
4:49AM INF 1 commits scanned.
4:49AM INF no leaks found
exit code: 0
```

That is the fixture's final commit — the
one-letter typo fix — and it is clean.
The same aim at the one bad commit tells
the opposite story:

```bash
gitleaks git --log-opts="93db213d43f1d05905743ab429c59ecf8c91abe0^..93db213d43f1d05905743ab429c59ecf8c91abe0" .
```

```text
4:49AM INF 1 commits scanned.
4:49AM WRN leaks found: 1
exit code: 1
```

The shapes worth memorising:

- `HEAD~1..HEAD` — the latest commit;
  what a pre-push check roughly means.
- `<base>..HEAD` — everything a branch or
  pull request adds over its base; this is
  the CI shape, and chapter 10 uses it.
  (On a cloned-for-CI repository, beware
  the shallow clone: a checkout that only
  fetched a few commits gives the scanner
  only those commits to see. Chapter 14
  returns to this.)
- A single commit, `hash^..hash` — the
  forensic shape: did *this* change do it?

## Report formats: JSON, and the rest

Chapter 5 wrote a **JSON** report and
read it with jq; it is the format to
reach for when you will process findings
yourself — counting them, grouping by
rule (`jq -r '.[].RuleID' report.json |
sort | uniq -c` is a triage session in
one line), feeding a dashboard. The other
formats exist for other consumers:

- **SARIF** — the format code-scanning
  platforms speak, GitHub's included: a
  report uploaded as SARIF appears as
  alerts on the repository's Security tab,
  one per finding, pinned to file and
  line. The lab generated one
  (transcript
  `gitleaks-lab/transcripts/t10-sarif.txt`):

  ```bash
  gitleaks git --report-format sarif --report-path ../report.sarif .
  jq '{version: .version, runs: (.runs | length), results: (.runs[0].results | length)}' ../report.sarif
  ```

  ```json
  {
    "version": "2.1.0",
    "runs": 1,
    "results": 6
  }
  ```

  SARIF 2.1.0, one run, six results — the
  same six findings, dressed for a
  platform.
- **CSV** — for spreadsheets and the
  meetings that love them.
- **JUnit** — for CI systems that display
  test-style results; each finding becomes
  a failing test, which is an honest
  description of it.
- **Template** — `--report-format
  template` with `--report-template`
  renders findings through a Go template
  of your own, for formats nobody
  anticipated.

Every format carries the same content
the JSON does — including, chapter 5's
warning applies to all of them, the
secrets in clear text. A report is a
snapshot of everything you most do not
want loose, in a file that looks
harmless. Handle, store and delete it
accordingly.

## Putting the two halves together

A realistic CI step, in the shape chapter
10 will complete, is now within reach:
check out the pull request's commits,
scan the range it adds, let the exit
code speak:

```bash
gitleaks git --log-opts="origin/main..HEAD" .
```

Nothing after that line runs if it
fails. The findings print in the job log
for the author to read — which is one
more place a real secret would end up
written down, and one more reason the
pre-commit hook of chapter 10, which
stops the secret before it is ever
committed, is the better wall. CI is the
net below it.
