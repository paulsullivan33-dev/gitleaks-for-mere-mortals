# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 13 names what the tool
   cannot do: the secrets it has no rule for, the secret half
   of a cloud key pair that its default rules let pass, keys
   split or encoded past recognition, the example keys and test
   values its patterns cannot tell from real ones, and why a
   clean scan is a report, not a proof.
8. **The ethics rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *your repositories, your
   machines, or explicit permission* — before any procedure
   depends on it, and later chapters point back to it where the
   tooling would make crossing the line easy. The standing
   companion rule is stated with it: a secret the scanner finds
   is treated as compromised and rotated, never just deleted.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu 24.04 sandbox.
Gitleaks **8.30.1** was installed from the project's official
release tarball for Linux x64, downloaded from the gitleaks
GitHub releases page, and its SHA-256 matched the checksum
published with the release before the binary was run (t00).
No package manager and no container were involved. The lab's
practice repository — a nine-commit project with planted,
invented secrets in its history — is built by
`gitleaks-lab/make-fixture.sh`, and every scan in the guide ran
against it or against a plain folder the lab made for the
purpose. All transcripts live in `gitleaks-lab/transcripts/`.

Run for real, with transcripts as evidence:

- Install and version, with the release checksum verified
  against the project's published checksums file (t00).
- A full history scan of the fixture (`gitleaks git`), summary
  and verbose: six findings covering a cloud access key ID, a
  generic API token, a GitHub token, a private key, and the
  tests' dummy token, each attributed to the commit that
  introduced it, with exit code 1 (t01).
- The JSON report, read back with jq, and one finding examined
  field by field, fingerprint included (t02).
- A redacted scan (`--redact`), showing what is safe to paste
  into a ticket and what is not (t03).
- The deletion that deletes nothing: the credentials file is
  absent at HEAD, shown present in its commit with plain git,
  and its removal commit inspected (t04).
- Folder scans (`gitleaks dir`) of a loose non-git folder (two
  findings) and of the fixture's working tree at HEAD (three
  findings — only the ones still present), plus a piped stdin
  scan (t05).
- Commit-range scans with `--log-opts`: the whole history
  (exit 1), the final clean commit alone (exit 0), and the one
  bad commit alone (exit 1) (t06).
- A known false positive suppressed by fingerprint with
  `.gitleaksignore`: the finding count drops from six to five
  and the rest still report (t07).
- A project rule of the lab's own (`skywatch-token`) added
  through `.gitleaks.toml` with `[extend] useDefault = true`:
  both project tokens are then reported under the project's
  rule, once each (t08).
- A baseline: today's report accepted as a baseline, the same
  scan then exits 0, and a new secret committed afterwards is
  still caught against that baseline (t09).
- The SARIF report, generated and read back with jq: SARIF
  version 2.1.0, one run, six results (t10).
- A plain git pre-commit hook running
  `gitleaks git --pre-commit --staged`: a commit carrying a
  planted token is refused, and a clean commit immediately
  afterwards goes through (t11).
- Three behaviours the guide relies on, each verified rather
  than assumed: the cloud secret half in the fixture's
  config file is *not* reported (the default rules catch the
  key ID and have no standalone rule for the secret half);
  the cloud provider's own documentation example key in the
  fixture's docs is *not* reported (the default rule carries
  an allowlist for values ending in EXAMPLE); and the private
  key is reported twice — once as written, once after
  Gitleaks decoded its base64 body looking for hidden
  secrets — under a single fingerprint (t01, t02).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- The official GitHub Action and the pre-commit framework
  integration (chapter 10). The plain git hook route was run
  for real (t11); the framework and the hosted runner were
  not.
- The Docker image and the package-manager installs
  (Homebrew, apt and friends) and building from Go source
  (chapter 3). The lab's verified route is the release
  tarball.
- Rewriting history to remove a secret (git filter-repo, the
  BFG Repo-Cleaner) and the force-push that follows it
  (chapters 6 and 11): named and explained, deliberately not
  performed on the fixture, and never a substitute for
  rotating the secret.
- Live verification of secrets against their services, the
  neighbouring tool TruffleHog's speciality (chapter 12):
  the lab's secrets are invented and there is nothing to
  verify them against. The comparison tools in chapter 12
  are characterised, not benchmarked.
- Hosted secret scanning and push protection on GitHub and
  GitLab (chapter 12), which run on the hosts' machines, not
  the lab's.

Fixtures are this guide's own and deliberately generic: a
nine-commit practice project (a weather fetcher talking to an
`.invalid` example API), five planted secrets, and a loose
folder of notes. Every planted value was invented for this
lab, is labelled as invented where it appears, and has never
been a real credential; one is the cloud provider's own
published documentation example, and one is the word "fake"
repeated and base64-encoded. No example is modelled on any
real person, network, service or organisation.
