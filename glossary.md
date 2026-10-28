# Glossary

**Allowlist** — config entries naming
paths, patterns or words that should
never be reported (chapter 9).

**Baseline** — a report accepted as
"known": later scans report only
findings whose fingerprints are not in
it (chapter 9).

**Config file** — `.gitleaks.toml`,
which adds or replaces rules and holds
allowlists. Without an `[extend]` block
it replaces the built-in rules entirely
(chapters 9 and 14).

**Decoding** — the detector's habit of
decoding base64-looking text and
scanning the result, several layers
deep; findings from it carry a
`decoded:base64` tag (chapters 2 and 5).

**Detector** — the engine that reads
text and produces findings; one engine
sits behind the `git`, `dir` and
`stdin` commands (chapter 2).

**Entropy** — a score for how
unpredictable a string looks. Real keys
score high; words and repeated padding
score low, and most rules have a floor
(chapter 2).

**Exit code** — the scan's
machine-readable verdict: 0 for no
findings, 1 (by default) for leaks,
other values for the scan itself
failing (chapter 8).

**Finding** — one reported match: rule,
file, line, secret, entropy and, for
history scans, the commit, author and
date that introduced it (chapter 5).

**Fingerprint** — the one-line name of a
finding, `commit:file:rule:line`, used
by the ignore file and the baseline
(chapter 5).

**Generic rule** — the built-in net that
reports a high-entropy value assigned
to a secret-smelling name (`token`,
`api_key`, `secret`…) as a
*generic-api-key* (chapter 2).

**History rewrite** — producing a new
history with a file or string scrubbed
out (git filter-repo, BFG), then
force-pushing it. Does not unpublish
anything (chapter 6).

**Hook (pre-commit)** — a script git
runs before a commit; a non-zero exit
vetoes the commit. Home of the staged
scan (chapter 10).

**Ignore file** — `.gitleaksignore`, one
fingerprint per line: the exact
findings accepted as known (chapter 9).

**Leak** — a secret found somewhere it
should not be; the state, not the act,
and the tool's name for its quarry.

**Log opts** — `--log-opts`, options
passed to `git log` to choose which
commits a scan covers (chapter 8).

**Private key** — the secret half of a
key pair, PEM files included; the half
that must never be committed (chapters
4 and 5).

**Push protection** — a host refusing a
push that contains recognisable
secrets, before it lands (chapters 10
and 12).

**Redact** — `--redact`, replacing
secrets in output with REDACTED so
findings can be shared safely
(chapter 5).

**Report** — the findings written to a
file: JSON, CSV, JUnit, SARIF or a
custom template. Contains the secrets
themselves (chapters 5 and 8).

**Rotate** — revoking a secret and
issuing a replacement; the only fix
that closes a leak (chapters 1, 6 and
11).

**Rule** — a pattern, usually a regular
expression plus an entropy floor and
keywords, describing one kind of secret
(chapter 2).

**SARIF** — the report format that
code-scanning platforms consume, so
findings appear as alerts beside the
code (chapter 8).

**Secret** — a string that unlocks
something: a password, an API key, a
token, a private key. Small, valuable,
and not meant to be read in a
repository.

**Staged scan** — `gitleaks git
--pre-commit --staged`, examining the
diff about to be committed (chapter
10).

**Stopword** — a word whose presence
marks a matched string as known-innocent
to a rule; one reason obviously fake
strings sometimes do not fire
(chapter 13).

**Verification** — a scanner asking the
issuing service whether a found key is
live; TruffleHog's speciality
(chapter 12).
