# Limits

By the end of this chapter you will know
the shapes of secret this tool does not
see, the alarms it raises that are not
secrets, and the correct weight to put
on a clean scan. Chapter 4's missing
secret was the trailer; here is the
feature. The theme underneath all of it:
Gitleaks matches **patterns and entropy
in text**. Everything it misses, and
everything it over-reports, follows from
that sentence.

## Secrets with no pattern to catch

- **The other half of the pair.** The
  lab's cloud secret key sat on the line
  under a key ID the scanner *did* catch,
  and was not reported: the default rules
  have no standalone rule for that
  40-character format, because on its own
  it looks like every other random string
  in the world. Formats are recognised;
  unstructured randomness is not, except
  where the generic net (below) happens
  to spread.
- **Human passwords.** `hunter2`, the
  dog's name with a digit, the password
  that is also used for everything else:
  low entropy by design, and invisible to
  a tool that uses unpredictability as
  its signal. A committed
  `password = "sunshine1"` may trip the
  generic rule on its variable name, or
  may not; do not plan around it.
- **Secrets for small or new services.**
  The rule book is large and grows, but a
  token format invented last month by a
  service nobody filed a rule for is just
  a string until the generic rule or a
  rule of your own (chapter 9) catches
  it.
- **Anything not made of text.** Secrets
  in screenshots, in a photographed
  whiteboard committed as a PNG, inside a
  compiled binary, spoken in a recording:
  outside the feedstock entirely. (Binary
  files are skipped by default, and
  images are allowlisted in the default
  config, for exactly this reason.)

## Secrets taken apart

- **Split and assembled.** A key broken
  into two halves in two files, or built
  at runtime from pieces (`"AKIA" +
  suffix`), shows the scanner no whole
  shape to match. The decode pass
  (chapter 5) reassembles base64 and a
  few other encodings — the lab watched
  it work — but it is not a decompiler,
  and deliberate fragmentation beats it.
- **Encrypted blobs.** A secret inside an
  encrypted file is, to the scanner,
  well-encrypted noise. That is the
  *correct* outcome if the encryption is
  real and the key lives elsewhere — and
  a blind spot if the "encryption" is a
  home-made scramble the scanner cannot
  undo but a reader could.
- **Outside the scanned range.** A scan
  sees the commits it is given. A shallow
  CI clone, a `--log-opts` range chosen
  too narrowly, a branch never fetched:
  the report will be accurate about what
  it saw and silent about the rest
  (chapter 14).

## Alarms that are not secrets

The other direction is just as real:

- **Test data and dummies.** Anything
  shaped like a key and random enough to
  pass entropy is reported, including the
  values invented precisely to be fake —
  the lab's dummy token outscored its
  real-shaped key on entropy. Chapter 9's
  tuning exists because of this, and so
  does its warning: every suppression is
  a small, deliberate act of trust.
- **Keys that are meant to be public.**
  Some tokens are public by design
  (certain client-side and publishable
  keys). The scanner cannot know your
  service's policy; it reports the shape
  and leaves the policy to you.
- **Examples in documentation.** Mostly
  handled — the cloud provider's own
  example key is quietly allowlisted by
  the default rule, ending-in-EXAMPLE and
  all — but every vendor's examples are
  a rule-writer's chase, and some will
  fire.

## The two rules, seen from the limits side

The limits sharpen both of chapter 1's
rules rather than softening them. The
permission rule matters more, not less,
because the tool is partial: running it
over someone else's repository gives you
an incomplete picture *and* crosses the
line — the worst of both. And the
rotation rule is untouched by anything
in this chapter: the scanner's job is to
decide what must be rotated, and a
secret it missed is still compromised —
your defence there is the doorway
(chapter 10) and the habit of keeping
secrets out of text in the first place,
not a better net.

## The honest summary

A scan that finds nothing means: *no
text in the scanned range matched the
current rules at their current settings.*
That is worth having — it is a real,
checkable statement, and for the common
shapes of accident (a pasted key, a
committed `.env`, a private key in a
folder) it catches the overwhelming
majority of what actually happens to
actual projects. It is not a certificate
that a repository is clean, and anyone
who sells it to you as one — or reports
it upward as one — has mistaken the map
for the territory. Scan, rotate what you
find, guard the door, and keep the
distinction.
