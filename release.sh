#!/usr/bin/env bash
# release.sh — tag a new version, update the Homebrew formula, push everything
# Usage: ./release.sh <version>   e.g.  ./release.sh 0.1.0
set -euo pipefail

VERSION="${1:-}"
[ -n "$VERSION" ] || { echo "usage: $0 <version>  (e.g. 0.1.0)" >&2; exit 1; }
TAG="v${VERSION}"

GITHUB_USER="afeldman"
GITHUB_REPO="scripts"
TARBALL_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/tags/${TAG}.tar.gz"
FORMULA="Formula/scripts.rb"

green()  { printf '\033[0;32m==> %s\033[0m\n' "$*"; }
red()    { printf '\033[0;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

# ── pre-flight ───────────────────────────────────────────────────────────────
[ -f "$FORMULA" ] || red "Run from repo root (Formula/scripts.rb not found)"
git diff --quiet && git diff --cached --quiet \
  || red "Working tree is not clean — commit or stash first"
git rev-parse "$TAG" >/dev/null 2>&1 \
  && red "Tag $TAG already exists"

# ── tag & push ───────────────────────────────────────────────────────────────
green "Creating tag $TAG ..."
git tag -a "$TAG" -m "release $TAG"

green "Pushing tag to GitHub ..."
git push origin "$TAG"

# ── compute sha256 ───────────────────────────────────────────────────────────
green "Downloading tarball to compute sha256 (may take a moment) ..."
# GitHub needs a few seconds to generate the archive after a fresh push
sleep 5
SHA256=$(curl -fsSL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')
green "sha256: $SHA256"

# ── update formula ───────────────────────────────────────────────────────────
green "Updating $FORMULA ..."

# Replace version, url, sha256 — or insert if not yet present
if grep -q '^  version ' "$FORMULA"; then
  sed -i '' "s|^  version .*|  version \"${VERSION}\"|" "$FORMULA"
else
  sed -i '' "s|^  homepage .*|&\n  version \"${VERSION}\"|" "$FORMULA"
fi

if grep -q '^  url ' "$FORMULA"; then
  sed -i '' "s|^  url .*|  url \"${TARBALL_URL}\"|" "$FORMULA"
else
  sed -i '' "s|^  version .*|&\n  url \"${TARBALL_URL}\"|" "$FORMULA"
fi

if grep -q '^  sha256 ' "$FORMULA"; then
  sed -i '' "s|^  sha256 .*|  sha256 \"${SHA256}\"|" "$FORMULA"
else
  sed -i '' "s|^  url .*|&\n  sha256 \"${SHA256}\"|" "$FORMULA"
fi

# Remove head stanza once we have a real release
sed -i '' '/^  head /d' "$FORMULA"

# ── commit & push ────────────────────────────────────────────────────────────
git add "$FORMULA"
git commit -m "formula: bump to ${TAG}"
git push origin master

green "Released ${TAG}. Homebrew install:"
printf '    brew tap %s/%s https://github.com/%s/%s\n' \
  "$GITHUB_USER" "$GITHUB_REPO" "$GITHUB_USER" "$GITHUB_REPO"
printf '    brew install %s/%s/scripts\n' "$GITHUB_USER" "$GITHUB_REPO"
