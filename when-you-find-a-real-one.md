# When You Find a Real One

By the end of this chapter you will have
the order of operations for the day the
scan stops being an exercise — a live key,
in a real repository, with a date on it.
The steps are not complicated. Getting
them in the right *order* is the whole
discipline, because the instinctive first
move (delete it!) is the one that matters
least.

## Step 0: do not panic, and do not tidy

The finding is not made worse by an hour
of careful work, and it can be made much
worse by hurried work: a history rewrite
attempted before the facts are in, a
report file committed into the very
repository it describes, a secret pasted
into a ticket "for reference". Work the
steps. Write down what you find as you
go — privately, and without pasting the
secret anywhere it does not already live.

## Step 1: establish the facts

From the finding and a little git, answer
four questions:

- **What is it?** The rule names the kind;
  the file and surrounding code say what
  it unlocks — a cloud account, a
  database, a deploy pipeline. If you
  cannot tell, treat it as live and
  powerful until shown otherwise.
- **When did it land?** The finding's
  commit and date open the exposure
  window. Everything between then and now
  is the period to think about.
- **Where has it been published?** Every
  remote the repository was ever pushed
  to, every fork, every clone. Public for
  even a short time means: assume it was
  copied by strangers, because automated
  collectors watch public pushes for
  exactly this, and they are fast.
- **Is it still live?** Sometimes the key
  was already revoked for unrelated
  reasons. Good news if so — and it is
  news to *verify* with the service, not
  to assume.

## Step 2: rotate — before anything else

**Revoke the old secret and issue a new
one.** Update the places the new secret
legitimately lives (your secret store,
your deployment configuration — not your
code), and confirm the service works
with the new one and refuses the old.
This is the step that closes the hole,
and it is the step the guide's second
rule (chapter 1) exists to protect:
nothing else on this list unpublishes
the old value, so the old value must stop
working.

Everything else — history, notifications,
post-mortems — happens with the hole
already closed. If the secret is not
yours to rotate (it belongs to a client,
an employer, a collaborator), this step
becomes *tell the owner, now, through a
channel that is not the repository*, and
help them rotate.

## Step 3: look for use

During the exposure window, was the key
used by anyone unexpected? Cloud and
service audit logs can usually answer
this for their own keys: logins, API
calls, from where, doing what. This
step decides whether the episode was an
embarrassment or an incident with a
blast radius — unknown usage means the
investigation widens beyond this guide,
to your organisation's incident process
if you have one, and to professional
help if the secret guarded anything that
matters. Do not skip the question just
because the likely answer is "nobody".

## Step 4: clean up, in the right order

Only now, with the secret dead:

- **Decide about history.** Rewriting
  (chapter 6) is optional cosmetics for a
  *rotated* secret: it keeps future
  readers from finding a dead string and
  wondering. It is disruptive (new hashes,
  re-clones, coordination), it cannot
  reach forks and caches, and it must
  never be the reason rotation waited.
  Many teams, for a rotated secret in an
  internal repository, skip it entirely.
- **Mind the evidence.** Delete scan
  reports you no longer need, and keep
  them out of the repository always.
- **Notify the clone-holders** if the
  history is rewritten or the repository
  was shared: their copies still hold the
  old history, and now you can tell them
  the secret in it is dead.
- **Record the episode** briefly: what,
  when, how long exposed, what rotated,
  what was checked. Written while it is
  fresh, it is the document future audits
  and future you will want.

## Step 5: close the door it came through

Ask how the secret got committed, and
change the thing that made it easy: the
hook goes in (chapter 10), the CI check
goes on, the config moves to environment
variables or a secret store, the README
learns the sentence "never commit
credentials", and the scanner joins the
regular maintenance round so the next
one is found by routine rather than by
accident. A leak that produces no change
is a leak scheduled to recur with a
different key.

## The small-print cases

- **The secret is in someone else's
  public repository.** Not yours to scan
  by this guide's first rule, and
  definitely not yours to test. If you
  stumble on one in code you legitimately
  use, the decent move is a private note
  to the owner saying where it sits —
  most hosts have a security contact
  route — and nothing else.
- **The secret is a password to a
  person's account,** not a service key.
  Same rotation, faster: accounts get
  reused, and the owner may not know the
  repository exists.
- **You are not sure it is real.** Treat
  it as real until the owner of the
  service confirms it is not. The cost of
  rotating a dead key is minutes; the
  cost of shrugging at a live one is the
  rest of this chapter, later, worse.

The fixture's secrets were invented, so
the lab never ran these steps for real —
they are procedure, not transcript, and
the guide labels them so. They are,
however, the entire reason the other
thirteen chapters exist.
