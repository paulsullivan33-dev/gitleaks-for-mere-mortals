# Installing Gitleaks

By the end of this chapter Gitleaks will
be on your machine, at a version you can
name, obtained in a way you can defend.
Gitleaks is a single self-contained
program written in Go, so "installing"
mostly means fetching one file and
putting it somewhere on your path. The
lab's verified route is the project's own
release download, checked against the
project's published checksums; the other
routes are named at the end and labelled
as what they are — documented, not run
here.

## The release download

The project's home is on GitHub, under
`gitleaks/gitleaks`, and each release
publishes ready-made archives per
operating system and processor, a file of
SHA-256 checksums, and nothing to phone
home to afterwards. The lab downloaded
version **8.30.1** for 64-bit Linux:

```bash
curl -LO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz
curl -LO https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_checksums.txt
```

Pick the archive that matches your
machine on the releases page — the names
say what they are (`linux_x64`,
`linux_arm64`, `darwin_arm64` for recent
Macs, `windows_x64`, and more).

## Verify before you run it

A scanner you will trust with your
repositories' secrets should itself
arrive by a route you checked. The
checksums file lists the expected SHA-256
for every archive in the release. Compare
yours before unpacking anything:

```bash
sha256sum gitleaks_8.30.1_linux_x64.tar.gz
grep linux_x64 gitleaks_8.30.1_checksums.txt
```

Check: the two lines carry the same hash.
The lab's transcript
`gitleaks-lab/transcripts/t00-version.txt`
shows both, equal:

```text
551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb  gitleaks_8.30.1_linux_x64.tar.gz
551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb  gitleaks_8.30.1_linux_x64.tar.gz
```

A mismatch means the download is not what
the project published — corrupted, or
worse, substituted — and the correct move
is to delete it and fetch it again, not
to proceed hopefully.

## Unpack and place

```bash
tar -xzf gitleaks_8.30.1_linux_x64.tar.gz gitleaks
sudo install -m 0755 gitleaks /usr/local/bin/
```

The archive also contains a licence file
and the project's README; the program
itself is the single `gitleaks` file.
Any directory on your `PATH` will do —
a personal `~/bin` is as good as
`/usr/local/bin`.

Now the check that closes the chapter:

```bash
gitleaks version
```

```text
8.30.1
```

## The other routes (documented only)

The lab ran the release download above
and nothing else; these routes are from
the project's documentation and are
listed so you know they exist, not
because this guide verified them:

- **Package managers.** Homebrew
  (`brew install gitleaks`), various Linux
  distribution packages, and other
  managers carry it. Convenient; the
  version may lag the releases page.
- **Docker.** The project publishes an
  image (`zricethezav/gitleaks` and a
  GitHub Container Registry variant) that
  runs the scanner with a repository
  mounted into the container.
- **From source.** With Go installed,
  `go install
  github.com/zricethezav/gitleaks/v8@latest`
  builds it locally.
- **The pre-commit framework and the
  GitHub Action** install it for you as
  part of their own machinery; chapter 10
  covers both in place.

Whichever route you take, finish with
`gitleaks version` and write the version
down next to any scan results you keep.
Findings are only comparable between runs
when the rules were the same, and the
rules travel with the version.

## A note on currency

Secret scanners live or die by their rule
sets, and new token formats appear
constantly: the 8.30.1 rule book knows
formats that did not exist when this
guide's lab ran earlier drafts. Updating
is the same download-and-verify dance
with a newer archive. If a scan of an old
repository matters — before a release,
before a handover — it is worth doing
with a current version, and saying which
one, so the result can be repeated.
