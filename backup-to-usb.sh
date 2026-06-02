#!/usr/bin/env bash
# Backup Mac settings + secrets to a USB drive for fast disaster recovery.
#
# Writes an offline twin of this repo to the USB:
#   <USB>/mac-backup/repo/            full copy of mac-stuff (plaintext, browsable)
#   <USB>/mac-backup/secrets.sparseimage   AES-256 encrypted private keys/creds
#   <USB>/mac-backup/RESTORE.md       step-by-step rebuild guide
#
# Idempotent. Safe to re-run weekly. Refreshes Brewfile / npm globals / public
# key from the live machine, then rsyncs everything to the drive.
#
# Requires: terminal app granted Full Disk Access (or Removable Volumes) in
# System Settings -> Privacy & Security, otherwise the drive is unreadable.

set -euo pipefail

# =============================================================================
# Config
# =============================================================================
USB_VOL="/Volumes/CL256GB"
DEST="$USB_VOL/mac-backup"
REPO="$(cd "$(dirname "$0")" && pwd)"
SPARSE="$DEST/secrets.sparseimage"
VOLNAME="mac-secrets"
SIZE="2g"                 # sparse: grows on demand up to this cap

# =============================================================================
# Preflight
# =============================================================================
echo "=== Mac backup to USB ==="

if [ ! -d "$USB_VOL" ]; then
  echo "ERROR: $USB_VOL not mounted. Plug in the drive and retry." >&2
  exit 1
fi

if ! touch "$USB_VOL/.cl-write-test" 2>/dev/null; then
  echo "ERROR: cannot write to $USB_VOL." >&2
  echo "  1. Grant your terminal Full Disk Access (System Settings ->" >&2
  echo "     Privacy & Security -> Full Disk Access), then QUIT & reopen it." >&2
  echo "  2. If still failing, the volume is owned by root. Run once:" >&2
  echo "       sudo chown \"\$(whoami)\" \"$USB_VOL\"" >&2
  echo "     or Finder -> Get Info -> uncheck 'Ignore ownership on this volume'." >&2
  exit 1
fi
rm -f "$USB_VOL/.cl-write-test"

mkdir -p "$DEST"
command -v rsync >/dev/null || { echo "ERROR: rsync not found." >&2; exit 1; }

# =============================================================================
# Refresh volatile repo content from the live machine
# =============================================================================
echo "Refreshing Brewfile..."
brew bundle dump --force --file="$REPO/Brewfile"

echo "Refreshing npm globals list..."
npm ls -g --depth=0 --parseable 2>/dev/null \
  | tail -n +2 | sed 's#.*/node_modules/##' | sort -u > "$REPO/npm-globals.txt"

echo "Refreshing public SSH key..."
if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  cp "$HOME/.ssh/id_rsa.pub" "$REPO/ssh/id_rsa.pub"
fi

# Dotfiles in dotfiles/ are the symlink source for ~/, so they are already
# current — no copy-back needed (that would be circular).

# =============================================================================
# Mirror repo to USB (plaintext, browsable)
# =============================================================================
echo "Syncing repo -> $DEST/repo/ ..."
rsync -a --delete --exclude='.DS_Store' "$REPO/" "$DEST/repo/"

# =============================================================================
# Encrypted secrets image
# =============================================================================
read -r -s -p "Passphrase for encrypted secrets image: " PASS; echo
if [ ! -f "$SPARSE" ]; then
  read -r -s -p "Confirm passphrase (new image): " PASS2; echo
  [ "$PASS" = "$PASS2" ] || { echo "ERROR: passphrases differ." >&2; exit 1; }
  echo "Creating encrypted image ($SIZE cap, AES-256)..."
  printf '%s' "$PASS" | hdiutil create -size "$SIZE" -type SPARSE -fs APFS \
    -encryption AES-256 -stdinpass -volname "$VOLNAME" \
    "${SPARSE%.sparseimage}" >/dev/null
fi

MNT="$(mktemp -d /tmp/mac-secrets.XXXXXX)"
cleanup() { sync; hdiutil detach "$MNT" >/dev/null 2>&1 || true; rmdir "$MNT" 2>/dev/null || true; }
trap cleanup EXIT

echo "Mounting secrets image..."
printf '%s' "$PASS" | hdiutil attach "$SPARSE" -stdinpass -nobrowse -mountpoint "$MNT" >/dev/null

# Copy a directory's contents into <image>/<sub>/ if the source exists.
secure_dir() {  # <source-dir-relative-to-home> <dest-sub>
  local src="$HOME/$1" sub="$2"
  if [ -d "$src" ]; then
    mkdir -p "$MNT/$sub"
    rsync -a --delete "$src/" "$MNT/$sub/"
    echo "  + $sub/  (from ~/$1)"
  else
    echo "  - skip (absent): ~/$1"
  fi
}
# Copy a single file into <image>/<sub>/ if it exists.
secure_file() {  # <source-file-relative-to-home> <dest-sub>
  local src="$HOME/$1" sub="$2"
  if [ -f "$src" ]; then
    mkdir -p "$MNT/$sub"
    rsync -a "$src" "$MNT/$sub/"
    echo "  + $sub/$(basename "$1")"
  else
    echo "  - skip (absent): ~/$1"
  fi
}

echo "Copying secrets into encrypted image..."
# --- SSH ---
secure_dir  ".ssh" "ssh"
# --- Git + shell identity / token-bearing rc files ---
secure_file ".gitconfig" "git"
secure_file ".netrc"     "git"
secure_file ".npmrc"     "git"
# --- Cloud CLI credentials ---
secure_dir  ".aws"               "cloud/aws"
secure_dir  ".azure"             "cloud/azure"
secure_dir  ".config/gh"         "cloud/gh"
secure_file ".docker/config.json" "cloud/docker"
# --- AI tooling auth (may be stale on restore; re-auth expected) ---
secure_file ".claude.json" "ai"
secure_dir  ".mcp-auth"    "ai/mcp-auth"
secure_dir  ".codex"       "ai/codex"
secure_dir  ".gemini"      "ai/gemini"

cleanup
trap - EXIT
echo "Secrets image unmounted."

# =============================================================================
# Regenerate RESTORE.md
# =============================================================================
echo "Writing RESTORE.md..."
cp "$REPO/RESTORE.md" "$DEST/RESTORE.md"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=== Done ==="
echo "Repo mirror : $(du -sh "$DEST/repo" 2>/dev/null | cut -f1)"
echo "Secrets img : $(du -sh "$SPARSE" 2>/dev/null | cut -f1)"
echo "Location    : $DEST"
echo ""
echo "WARNING: tokens hard-coded in ~/.zshrc are NOT in the encrypted image —"
echo "  .zshrc is a tracked dotfile and lives plaintext in repo/. Keep real"
echo "  secrets out of .zshrc; use .npmrc/.netrc (encrypted) or 1Password."
