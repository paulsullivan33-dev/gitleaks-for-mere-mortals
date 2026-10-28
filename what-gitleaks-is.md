# What Gitleaks Is

Every project of any age has a moment like
this: someone needed the program to talk
to a service, so they pasted the password
or the API key straight into the code,
committed it, and meant to move it later.
Later took a while. Sometimes later never
came, and even when it did — when the key
was moved out and the file deleted — the
commit that added it stayed in the
project's history, where anyone with a
copy of the repository can still read it.

**Gitleaks is a scanner that searches a
git repository for secrets**: passwords,
API keys, access tokens, private keys —
the small strings that unlock things. It
reads every commit in the history, not
just the files as they are today, and
reports each suspicious string with the
commit that introduced it, the file and
line it sits on, and who wrote it. It can
also scan plain folders and text piped to
it, and it can stand in front of a commit
and refuse to let a new secret in.

The name says what it hunts: *leaks* —
secrets that ended up somewhere they were
never meant to stay.

## Why anyone would do this

Three honest reasons account for nearly
every legitimate use:

- **Taking stock.** You are about to make
  a repository public, hand it to a new
  employer, or share it with a contractor.
  Before anyone else reads the history,
  you want to know what is in it. A scan
  answers with a list, not a feeling.
- **Cleaning up properly.** Deleting a key
  from the code feels like fixing the
  problem. It is not, and chapter 6 shows
  why with a file that is gone at HEAD and
  still fully readable in its commit. The
  scanner tells you which secrets your
  history actually contains, so the real
  fix — rotating them — can start from
  facts.
- **Keeping it from happening again.** Run
  the scanner in a pre-commit hook or in
  continuous integration, and the next
  pasted key is stopped at the door
  instead of discovered next year
  (chapter 10).

## The rules, stated before everything else

A tool that finds secrets in repositories
can find secrets in *anyone's*
repositories, including ones that were
leaked, stolen, or published by mistake.
So this guide has two rules, and they are
not fine print:

> **Scan only repositories that are yours —
> on machines you own, or where the owner
> has given you explicit permission.**

> **A secret the scanner finds is treated
> as compromised. Rotate it — revoke the
> old one, issue a new one — rather than
> just deleting the line it sits on.**

The first rule covers the scanning. Your
own projects: yes. An employer's codebase
you are assigned to protect: yes, that is
the job. A stranger's leaked repository,
a celebrity's dotfiles, a "quick look" at
what a rival committed by accident: no.
Finding a working key in someone else's
history does not make it yours to use, to
test, or to keep.

The second rule covers what happens
after. A secret that has been committed
has been *published* — to everyone who
ever cloned the repository, every backup,
every fork. Deleting the file changes
what the next reader sees first. It does
not unpublish anything. Chapter 11 walks
through the proper response; the short
version is that rotation comes first and
history rewriting, if it happens at all,
comes second.

The lab in this guide obeyed both rules
in the strongest way available: the
repository it scans was invented for the
purpose, and every secret in it was made
up on the spot. One of them is the word
"fake" repeated and encoded. None of
them has ever opened anything.

## A familiar shape

Gitleaks is one program with three
commands you will use constantly
(chapter 2): **git**, which scans a
repository's history; **dir**, which
scans plain files and folders; and
**stdin**, which scans text piped to it.
A built-in set of **rules** — patterns
for known kinds of secrets, plus a
generic net for things that merely look
like keys — does the recognising, and
each match becomes a **finding** with a
**fingerprint** that identifies it
exactly. Findings can be printed, written
to report files, redacted for sharing,
and checked against a **baseline** so a
team can adopt the tool on a repository
that is not clean yet.

A first taste, after installing
(chapter 3). The lab builds a practice
repository whose history contains
planted secrets, then scans it:

```bash
./gitleaks-lab/make-fixture.sh leaky-app
cd leaky-app
gitleaks git .
```

Check: the summary at the end of the
scan reports what the lab's transcript
`gitleaks-lab/transcripts/t01-first-scan.txt`
shows — several findings, and an exit
code that says so:

```text
4:49AM INF 8 commits scanned.
4:49AM INF scanned ~2890 bytes (2.89 KB) in 275ms
4:49AM WRN leaks found: 6
exit code: 1
```

Six findings in a nine-commit practice
project. A real project with real history
tends to be worse, which is rather the
point of looking.

## Who it is for

The developer about to open-source a
project that grew up private. The team
lead who inherited a repository and a
nagging feeling. The freelancer handing
over a codebase and wanting to hand over
nothing else. The common thread is one
person, their own repositories, and a
question only the history itself can
answer: *what did we commit, and is it
still good?*

## What it is not

Gitleaks is not a vault: it does not store
secrets safely or hand them out to
programs — it finds them in the open,
which is a different job. It is not a
password manager, and it is not proof of
safety: a clean scan means its rules
found nothing, and chapter 13 is blunt
about the gap between *nothing found* and
*nothing there*. It is not a burglar's
tool either, whatever its abilities:
pointing it at repositories you do not
own crosses the first rule above, and no
chapter of this guide will help you do
it.
