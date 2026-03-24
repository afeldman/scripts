#!/usr/bin/env sh
# install.sh — afeldman/scripts installer
# Usage: curl -fsSL https://raw.githubusercontent.com/afeldman/scripts/master/install.sh | sh
set -eu

# ── config ───────────────────────────────────────────────────────────────────
GITHUB_USER="afeldman"
GITHUB_REPO="scripts"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# ── helpers ──────────────────────────────────────────────────────────────────
green()  { printf '\033[0;32m==> %s\033[0m\n' "$*"; }
yellow() { printf '\033[1;33mwarn: %s\033[0m\n' "$*"; }
red()    { printf '\033[0;31merror: %s\033[0m\n' "$*" >&2; exit 1; }
step()   { printf '\033[0;34m --- %s\033[0m\n' "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

# ── OS detection ─────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      red "Unsupported OS: $OS" ;;
esac

# ── homebrew (macOS) ─────────────────────────────────────────────────────────
if [ "$PLATFORM" = "macos" ]; then
  if ! has brew; then
    green "Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # add brew to PATH for the rest of this script
    if [ -x "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
fi

# ── system dependencies ──────────────────────────────────────────────────────
#
# Brew packages (macOS) — checked individually to skip already-installed ones
BREW_PACKAGES="openssl jq fzf gpg gum ffmpeg ghostscript rclone"

# APT packages (Linux) — same set where available
APT_PACKAGES="openssl jq fzf gpg ffmpeg ghostscript rclone"

install_brew_pkg() {
  pkg="$1"
  if brew list --formula 2>/dev/null | grep -q "^${pkg}\$"; then
    return 0
  fi
  step "brew install $pkg"
  brew install "$pkg"
}

install_apt_pkg() {
  pkg="$1"
  if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
    return 0
  fi
  step "apt-get install $pkg"
  sudo apt-get install -y "$pkg"
}

if [ "$PLATFORM" = "macos" ]; then
  green "Checking Homebrew packages ..."
  for pkg in $BREW_PACKAGES; do
    install_brew_pkg "$pkg"
  done

elif [ "$PLATFORM" = "linux" ]; then
  if has apt-get; then
    green "Checking APT packages ..."
    sudo apt-get update -qq
    for pkg in $APT_PACKAGES; do
      install_apt_pkg "$pkg"
    done
  else
    yellow "Non-Debian Linux detected — install manually: $APT_PACKAGES"
  fi
fi

# ── ruby gems ────────────────────────────────────────────────────────────────
# Required by: cp_n (parallel, concurrent-ruby, thor, colorize)
#              videocut (thor, colorize)
#              dublicate / dublicate_dir (uuid)
RUBY_GEMS="thor colorize concurrent-ruby parallel uuid"

if has ruby && has gem; then
  green "Checking Ruby gems ..."
  INSTALLED_GEMS="$(gem list 2>/dev/null)"
  for gem in $RUBY_GEMS; do
    # concurrent-ruby is listed as 'concurrent-ruby' but required as 'concurrent'
    list_name="$gem"
    if printf '%s' "$INSTALLED_GEMS" | grep -q "^${list_name} "; then
      continue
    fi
    step "gem install $gem"
    gem install "$gem"
  done
else
  yellow "Ruby not found — skipping gems (cp_n, videocut, dublicate will not work)"
fi

# ── resolve tarball URL ──────────────────────────────────────────────────────
if   has curl; then DOWNLOAD="curl -fsSL"
elif has wget; then DOWNLOAD="wget -qO-"
else red "curl or wget is required"; fi

has tar || red "tar is required"

LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/tags" \
  2>/dev/null | grep '"name"' | head -1 | sed 's/.*"name": *"\([^"]*\)".*/\1/' || true)

if [ -n "$LATEST_TAG" ]; then
  TARBALL_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/tags/${LATEST_TAG}.tar.gz"
  VERSION_LABEL="$LATEST_TAG"
else
  TARBALL_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/heads/master.tar.gz"
  VERSION_LABEL="master"
fi

# ── download & install scripts ───────────────────────────────────────────────
green "Downloading ${GITHUB_USER}/${GITHUB_REPO}@${VERSION_LABEL} ..."
mkdir -p "$INSTALL_DIR"
TMPDIR=$(mktemp -d)
# shellcheck disable=SC2064
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

$DOWNLOAD "$TARBALL_URL" | tar -xz -C "$TMPDIR"
EXTRACTED=$(ls -d "$TMPDIR"/*/  | head -1)

INSTALLED=0
SKIPPED=0

for f in "${EXTRACTED}"*; do
  name=$(basename "$f")
  case "$name" in
    install.sh|release.sh|uninstall.sh|CLAUDE.md|*.md|*.rb|.git*|Formula) continue ;;
  esac
  [ -f "$f" ] || continue
  first_line=$(head -1 "$f" 2>/dev/null || true)
  case "$first_line" in
    '#!'*)
      cp "$f" "$INSTALL_DIR/$name"
      chmod +x "$INSTALL_DIR/$name"
      INSTALLED=$((INSTALLED + 1))
      ;;
    *)
      SKIPPED=$((SKIPPED + 1))
      ;;
  esac
done

green "Installed ${INSTALLED} scripts to ${INSTALL_DIR} (${SKIPPED} skipped)"

# ── PATH setup ───────────────────────────────────────────────────────────────
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
PATH_COMMENT="# afeldman/scripts — added by installer"

add_to_path() {
  rc="$1"
  [ -f "$rc" ] || return 0
  grep -q '\.local/bin' "$rc" 2>/dev/null && return 0
  printf '\n%s\n%s\n' "$PATH_COMMENT" "$PATH_LINE" >> "$rc"
  green "Added \$HOME/.local/bin to PATH in $rc"
}

add_to_path "$HOME/.zshrc"
add_to_path "$HOME/.bashrc"
add_to_path "$HOME/.bash_profile"

# ── done ─────────────────────────────────────────────────────────────────────
case ":${PATH}:" in
  *":${INSTALL_DIR}:"*)
    green "Done. Scripts are ready to use." ;;
  *)
    yellow "Restart your shell or run:"
    printf '    export PATH="%s:$PATH"\n' "$INSTALL_DIR"
    green "Done." ;;
esac
