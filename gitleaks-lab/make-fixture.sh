#!/usr/bin/env bash
# Build the practice repository this guide scans: a small, ordinary
# project ("skywatch", a weather fetcher) whose git history contains
# several planted secrets. Every secret in it was invented for this
# lab, is labelled as such where it appears, and has never been a
# real credential for anything.
#
# Usage: ./make-fixture.sh [target-dir]   (default: ./leaky-app)
set -euo pipefail

TARGET="${1:-leaky-app}"

if [ -e "$TARGET" ]; then
  echo "error: $TARGET already exists; remove it first" >&2
  exit 1
fi

mkdir -p "$TARGET"
cd "$TARGET"
git init -q -b main
git config user.name "Pat Example"
git config user.email "pat@example.com"

# Fixed dates make the history identical on every run, commit
# hashes included, so the guide's transcripts match yours.
commit() { # commit <date> <message>
  local date="$1"; shift
  GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -q -m "$1"
}

# --- Commit 1: a clean start -------------------------------------
cat > skywatch.py <<'EOF'
#!/usr/bin/env python3
"""Fetch a weather summary for a town.

The API key comes from the SKYWATCH_API_KEY environment variable.
Nothing secret lives in this repository.
"""
import os
import sys

API_URL = "https://api.example-weather.invalid/v1"


def main() -> int:
    key = os.environ.get("SKYWATCH_API_KEY")
    if not key:
        print("set SKYWATCH_API_KEY first", file=sys.stderr)
        return 1
    print(f"would fetch {API_URL}/summary with a key (demo build)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF
cat > README.md <<'EOF'
# Skywatch

A tiny practice project: fetch a weather summary from an API.

Run it with:

    SKYWATCH_API_KEY=your-key-here python3 skywatch.py
EOF
git add .
commit "2026-01-05T09:00:00" "Initial commit: skywatch skeleton"

# --- Commit 2: cloud credentials hardcoded "while prototyping" ---
# Both values were invented for this lab. The key ID has the shape
# of the real thing; the secret half is labelled with what it is.
cat > config.py <<'EOF'
# Prototype settings. TODO: move these to the environment.
# Both values are invented samples planted for the scanning lab.
AWS_ACCESS_KEY_ID = "AKIAQ7XMP2K4RW6T5VZ3"
AWS_SECRET_ACCESS_KEY = "FakeSecret/Ab3dEf6hIjKlMnOpQrStUvWxYz012"
AWS_DEFAULT_REGION = "us-east-1"
EOF
git add .
commit "2026-01-06T10:30:00" "Hardcode cloud keys while prototyping"

# --- Commit 3: an upstream API token and a token in a script -----
cat > api_client.py <<'EOF'
"""Client for the upstream weather-data service."""
import urllib.request

# Token value invented for this lab; it was never issued by anyone.
WEATHER_API_TOKEN = "skw_live_9f8e7d6c5b4a39281706f5e4d3c2b1a098765432"


def fetch_summary(town: str) -> bytes:
    req = urllib.request.Request(
        f"https://api.example-weather.invalid/v1/summary?town={town}",
        headers={"Authorization": f"Bearer {WEATHER_API_TOKEN}"},
    )
    with urllib.request.urlopen(req) as resp:
        return resp.read()
EOF
mkdir -p tools
cat > tools/release.sh <<'EOF'
#!/usr/bin/env bash
# Publish a release. The token below was invented for the scanning
# lab; a real one must never be written into a script like this.
GH_TOKEN="ghp_X7kP2mQ9wR4tY8uI3oL6sD1fG5hJ0aBcDeFg"
echo "would publish with a token (demo build)"
EOF
chmod +x tools/release.sh
git add .
commit "2026-01-07T11:15:00" "Add upstream API client and release script"

# --- Commit 4: the credentials are "removed" ---------------------
git rm -q config.py
cat >> README.md <<'EOF'

Configuration now comes from environment variables only.
EOF
git add .
commit "2026-01-08T09:45:00" "Remove hardcoded keys, use the environment"

# --- Commit 5: a private key joins the repo ----------------------
# The body below is the word "fake" over and over, base64-encoded.
# It is shaped like a key and opens nothing.
cat > deploy_key.pem <<'EOF'
-----BEGIN RSA PRIVATE KEY-----
ZmFrZSBmYWtlIGZha2UgZmFrZSBmYWtlIGZha2UgZmFrZQ==
ZmFrZSBmYWtlIGZha2UgZmFrZSBmYWtlIGZha2UgZmFrZQ==
-----END RSA PRIVATE KEY-----
EOF
git add .
commit "2026-01-09T14:20:00" "Add deploy key for the demo server"

# --- Commit 6: ...and leaves again -------------------------------
git rm -q deploy_key.pem
git add .
commit "2026-01-10T08:05:00" "Remove deploy key, use an agent instead"

# --- Commit 7: documentation quotes the provider's example key ---
mkdir -p docs
cat > docs/key-formats.md <<'EOF'
# Key formats you will meet

Access key IDs from the cloud provider look like twenty letters
and digits. The provider's own documentation illustrates the
format with this example, which is not a real key:

    AKIAIOSFODNN7EXAMPLE

Our upstream service issues tokens with an `skw_live_` prefix
followed by forty hexadecimal characters.
EOF
git add .
commit "2026-01-11T16:40:00" "Document the key formats"

# --- Commit 8: the tests arrive, carrying a dummy token ----------
mkdir -p tests
cat > tests/test_api_client.py <<'EOF'
"""Offline tests: the dummy token below is a fixed test value.

It has the same shape as a real upstream token so the parsing
code path is exercised, but it was invented for these tests and
is not a credential. Scanners cannot tell the difference, which
is the subject of the tuning chapter.
"""
from api_client import fetch_summary  # noqa: F401  (import check)

DUMMY_TOKEN = "skw_live_1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d"


def test_dummy_token_shape() -> None:
    assert DUMMY_TOKEN.startswith("skw_live_")
    assert len(DUMMY_TOKEN) == len("skw_live_") + 40
EOF
git add .
commit "2026-01-12T10:00:00" "Add tests with a dummy token"

# --- Commit 9: a clean, boring HEAD ------------------------------
sed -i 's/fetch a weather summary/Fetch a weather summary/' README.md
git add .
commit "2026-01-13T09:10:00" "Fix a capital in the README"

echo "Fixture repository built in: $TARGET"
git -C . log --oneline | cat
