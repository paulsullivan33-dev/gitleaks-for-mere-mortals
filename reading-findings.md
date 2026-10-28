# Reading Findings

By the end of this chapter you will be
able to take a single finding apart —
where it lives, when it arrived, which
rule named it, what its fingerprint is
for — and to produce the two forms of
output you will actually use later: a
report file for machines, and a redacted
listing safe to show another human.

## One finding, field by field

The screen listing is fine for six
findings. Real repositories produce
hundreds, and they arrive as data. Write
a **report**:

```bash
gitleaks git --report-format json --report-path ../first-report.json .
jq length ../first-report.json
```

```text
6
```

(Jq is the standard tool for asking
questions of JSON files; any JSON reader
will do.) Now pull out the cloud finding
and look at all of it (transcript
`gitleaks-lab/transcripts/t02-json-report.txt`):

```bash
jq '.[] | select(.RuleID == "aws-access-token")' ../first-report.json
```

```json
{
  "RuleID": "aws-access-token",
  "Description": "Identified a pattern that may indicate AWS credentials, risking unauthorized cloud resource access and data breaches on AWS platforms.",
  "StartLine": 3,
  "EndLine": 3,
  "StartColumn": 23,
  "EndColumn": 42,
  "Match": "AKIAQ7XMP2K4RW6T5VZ3",
  "Secret": "AKIAQ7XMP2K4RW6T5VZ3",
  "File": "config.py",
  "SymlinkFile": "",
  "Commit": "93db213d43f1d05905743ab429c59ecf8c91abe0",
  "Entropy": 4.121928,
  "Author": "Pat Example",
  "Email": "pat@example.com",
  "Date": "2026-01-06T10:30:00Z",
  "Message": "Hardcode cloud keys while prototyping",
  "Tags": [],
  "Fingerprint": "93db213d43f1d05905743ab429c59ecf8c91abe0:config.py:aws-access-token:3"
}
```

Read the fields as answers to the
questions you would ask about any leak:

- **What is it?** `RuleID` names the rule
  that fired — `aws-access-token` — and
  `Description` says what the rule's
  authors think it means. `Match` and
  `Secret` carry the string itself, in
  clear text. Hold that thought; it
  matters below.
- **Where is it?** `File`, `StartLine`,
  and the columns: `config.py`, line 3 —
  in the version of the file that commit
  wrote. The file does not exist at HEAD;
  chapter 6 is about exactly that.
- **When, and whose?** `Commit`,
  `Author`, `Date` and `Message` give you
  the moment and the context: a Tuesday
  morning commit, honestly titled. Most
  real findings look like this — not
  malice, a shortcut with a TODO attached.
- **How sure is the tool?** `Entropy`
  scores the string's unpredictability
  (higher looks more machine-generated).
  It is evidence, not a verdict: the
  dummy token in the tests scores 4.44,
  *higher* than this real-shaped key's
  4.12, and it is a test value.
- **What do I call it?** The
  `Fingerprint` — commit, file, rule,
  line, joined by colons. It names this
  finding uniquely without quoting the
  secret, and it is the handle the ignore
  file and the baseline use (chapter 9).

## The secret is in the report

Notice what just happened: to describe
the leak, the tool wrote the leaked
string into a JSON file on your disk,
twice. This is normal and necessary —
a report that hid the evidence could not
be acted on — but it makes **every report
a sensitive file**. Do not commit reports
into the repository they describe (a
finding the lab sees in the wild with
embarrassing frequency), do not attach
them to tickets readable by people who
should not hold the keys, and delete
them when the work is done. The lab's
reports live outside the practice
repository, in the folder above it, for
exactly this reason.

## Redaction: the shareable form

When the audience needs the *shape* of
the findings but not the keys themselves
— a ticket, a chat message, a report to
a manager — scan with `--redact`:

```bash
gitleaks git --verbose --redact .
```

Findings keep their rules, files, lines,
commits and fingerprints, but the secret
itself is replaced (transcript
`gitleaks-lab/transcripts/t03-redact.txt`):

```text
Finding:     REDACTED
Secret:      REDACTED
RuleID:      aws-access-token
Entropy:     4.121928
File:        config.py
Line:        3
Commit:      93db213d43f1d05905743ab429c59ecf8c91abe0
```

`--redact=50` hides half of each secret,
which is sometimes useful for confirming
"yes, that is the key I think it is"
without printing all of it. Full
redaction is the safer default: a
fingerprint identifies a finding to
anyone who needs to act on it, without
spreading the secret one copy further.

## The duplicate, resolved

Chapter 4 left a loose end: the private
key was reported twice. The JSON report
shows why (t02 holds both records). The
two findings are identical in rule, file,
line, commit and fingerprint; they
differ in `Tags` and in the secret's
body. One is the key as written. The
other carries the tags `decoded:base64`
and `decode-depth:1`, and its body is the
base64 *decoded* — the word "fake"
repeated in plain text. The detector
decoded the key's body, because secrets
are commonly stashed in encodings, and
found a key-shaped object in the decoded
text too: the header and footer are not
encoded, so the decoded fragment still
wears them.

Treat the pair as what it is: **one
secret, two sightings.** Anything counted
by fingerprint — the ignore file, the
baseline, your own triage notes — counts
it once. And take the wider lesson with
you into chapter 13: encoding a secret
does not hide it from a scanner that
decodes as it goes.
