# The Neighbours

By the end of this chapter you will know
what the tools around Gitleaks do
differently, so you can choose by the
question you are asking rather than by
habit. These tools are characterised,
not benchmarked: the lab ran Gitleaks
and nothing else, and the descriptions
below come from each project's own
documentation.

## TruffleHog: the one that checks

**TruffleHog** (Truffle Security) scans
not just git history but filesystems,
cloud storage, issue trackers and more —
and its defining trick is
**verification**: for the hundreds of
secret types it recognises, it can ask
the issuing service whether the key is
*live*. That changes triage completely.
A Gitleaks report says "this looks like
a key"; a verified TruffleHog report
says "this key works". Verification is
also its sharp edge: the tool must make
real requests with found credentials,
which is an act chapter 1's rules have
opinions about on repositories that are
not yours, and it needs network access
and care in where its results go. If
your question is *which of these forty
findings are emergencies*, verification
is the answer; the lab's secrets were
invented, so there was nothing to verify
them against, and this guide did not run
it.

## detect-secrets: the baseline-first one

Yelp's **detect-secrets** was built for
the adoption problem chapter 9 solved
with a baseline: it expects to run in
pre-commit, keeps an audited baseline
file of known findings as a first-class
part of the workflow, and leans on
plugins plus entropy analysis rather
than a giant rule book. Projects that
live in the pre-commit framework often
find it the more natural fit. Its
question is *did this change add a
secret?*, asked continuously, rather
than *what does all of history hold?*,
asked in an audit.

## git-secrets: the prevention hook

AWS's **git-secrets** is older, smaller
and aimed at the doorway: it hooks into
git to *prevent* commits and merges
containing patterns — AWS keys above
all — and can scan history as a
secondary act. It does less than
Gitleaks in every direction and is
correspondingly simple to reason about.
If the only secrets you fear are one
cloud provider's and the only moment
you care about is the commit, it is
still a respectable fence.

## The hosts' own scanners

**GitHub secret scanning** watches
repositories on the platform for a wide
range of partners' token formats, alerts
the owner — and, for many formats,
notifies the *issuing service*, which
may revoke the key automatically. Its
**push protection** moves the check to
the moment of the push and refuses.
GitLab offers its own secret detection
in its pipelines and on the platform.
These have the unbeatable advantage of
position: they see every push to the
host, from every machine, with no local
installation to forget. Their limit is
the mirror image: they see nothing that
does not reach the host, and nothing on
other hosts. Chapter 10's third wall;
turn it on where it exists, and keep
your own scanner for everywhere else.

## Also in the street

- **Talisman** (ThoughtWorks) — a git
  hook that checks outgoing commits for
  secrets and large or suspicious files;
  lives at the same doorway as this
  guide's chapter 10.
- **ggshield** (GitGuardian) — a
  commercial scanner's command-line face,
  with its own large rule set and a
  hosted dashboard behind it; the
  polished end of the market, priced
  accordingly.
- **Your platform's vault and CI
  scanners** — cloud providers and CI
  systems increasingly bundle secret
  detection into their pipelines; often
  shallower than a dedicated tool, but
  already switched on.

## Choosing

The tools divide by the question:

- *What has this repository ever
  contained?* — a history scanner:
  Gitleaks, or TruffleHog.
- *Which of these findings are live?* —
  verification: TruffleHog, cautiously,
  on your own repositories.
- *How do we stop the next one at the
  door?* — hooks and push protection:
  chapter 10's stack, detect-secrets,
  git-secrets, the hosts.
- *How do we adopt on a dirty
  repository without stopping work?* —
  baselines: Gitleaks (chapter 9) or
  detect-secrets.

They also compose. Nothing stops a team
running Gitleaks in CI, push protection
on the host, and a quarterly TruffleHog
verification pass over the findings —
except the discipline to read what the
scans say, which no tool in this chapter
supplies.
