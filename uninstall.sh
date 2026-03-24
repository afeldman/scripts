#!/usr/bin/env sh
# uninstall.sh — remove all afeldman/scripts from $HOME/.local/bin
set -eu

GITHUB_USER="afeldman"
GITHUB_REPO="scripts"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

green()  { printf '\033[0;32m==> %s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33mwarn: %s\033[0m\n' "$*"; }
red()    { printf '\033[0;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# ── fetch script list from GitHub ────────────────────────────────────────────
if   has curl; then FETCH="curl -fsSL"
elif has wget; then FETCH="wget -qO-"
else red "curl or wget required"; fi

has tar || red "tar is required"

green "Fetching script list from GitHub ..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

LATEST_TAG=$($FETCH "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/tags" \
  2>/dev/null | grep '"name"' | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/' || true)

if [ -n "$LATEST_TAG" ]; then
  TARBALL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/tags/${LATEST_TAG}.tar.gz"
else
  TARBALL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/heads/master.tar.gz"
fi

$FETCH "$TARBALL" | tar -xz -C "$TMPDIR"
EXTRACTED=$(ls -d "$TMPDIR"/*/ | head -1)

# ── remove installed scripts ─────────────────────────────────────────────────
REMOVED=0
for f in "${EXTRACTED}"*; do
  name=$(basename "$f")
  target="$INSTALL_DIR/$name"
  [ -f "$target" ] || continue
  rm "$target"
  REMOVED=$((REMOVED + 1))
done

green "Removed ${REMOVED} scripts from ${INSTALL_DIR}"

# ── clean PATH entries ────────────────────────────────────────────────────────
remove_from_path() {
  rc="$1"
  [ -f "$rc" ] || return 0
  grep -q 'afeldman/scripts' "$rc" 2>/dev/null || return 0
  # remove the comment line and the export line that follows
  tmp="$(mktemp)"
  grep -v 'afeldman/scripts' "$rc" | grep -v '\.local/bin.*PATH\|PATH.*\.local/bin' > "$tmp" || true
  mv "$tmp" "$rc"
  yellow "Cleaned PATH entry from $rc — review manually if needed"
}

remove_from_path "$HOME/.zshrc"
remove_from_path "$HOME/.bashrc"
remove_from_path "$HOME/.bash_profile"

green "Done."
