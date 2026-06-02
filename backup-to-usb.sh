#!/usr/bin/env bash
# Backup Mac settings + secrets to a USB drive for fast disaster recovery.
#
# Each run creates a timestamped snapshot and keeps the 3 most recent:
#   <USB>/mac-backup/
#   ├── RESTORE.md                       rebuild guide (plaintext)
#   ├── latest -> snapshots/<newest>     convenience symlink
#   └── snapshots/
#       └── <YYYY-MM-DD-HHMMSS>/
#           ├── repo/                    plaintext copy of mac-stuff
#           └── secrets.sparseimage      AES-256 encrypted keys/creds
#
# Retention: after writing the new snapshot, the oldest is pruned so exactly
# 3 generations remain (the two previous + the one just made).
#
# Idempotent. Refreshes Brewfile / npm globals / public key from the live
# machine each run. Requires the terminal app to have Full Disk Access (or
# Removable Volumes) in System Settings -> Privacy & Security.

set -euo pipefail

# =============================================================================
# Config
# =============================================================================
USB_VOL="/Volumes/CL256GB"
DEST="$USB_VOL/mac-backup"
SNAP_ROOT="$DEST/snapshots"
REPO="$(cd "$(dirname "$0")" && pwd)"
VOLNAME="mac-secrets"
SIZE="2g"                 # sparse: grows on demand up to this cap
KEEP=3                    # snapshots to retain

STAMP="$(date +%Y-%m-%d-%H%M%S)"   # Oslo local time; sorts chronologically
SNAP="$SNAP_ROOT/$STAMP"
SPARSE="$SNAP/secrets.sparseimage"

# =============================================================================
# Preflight
# =============================================================================
echo "=== Mac backup to USB ($STAMP) ==="

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

command -v rsync >/dev/null || { echo "ERROR: rsync not found." >&2; exit 1; }

# Newest existing snapshot (the one we clone the secrets image from), if any.
PREV=""
if [ -d "$SNAP_ROOT" ]; then
  PREV="$(ls -1d "$SNAP_ROOT"/*/ 2>/dev/null | sort | tail -1 || true)"
  PREV="${PREV%/}"
fi
mkdir -p "$SNAP"

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
# Mirror repo into the new snapshot (plaintext, browsable)
# =============================================================================
echo "Syncing repo -> $SNAP/repo/ ..."
rsync -a --delete --exclude='.DS_Store' "$REPO/" "$SNAP/repo/"

# =============================================================================
# Encrypted secrets image (clone prior, else create)
# =============================================================================
read -r -s -p "Passphrase for encrypted secrets image: " PASS; echo

if [ -n "$PREV" ] && [ -f "$PREV/secrets.sparseimage" ]; then
  echo "Cloning previous secrets image (APFS copy-on-write)..."
  cp -c "$PREV/secrets.sparseimage" "$SPARSE"
else
  read -r -s -p "Confirm passphrase (first image): " PASS2; echo
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
# RESTORE.md + latest symlink
# =============================================================================
echo "Writing RESTORE.md and latest -> $STAMP ..."
cp "$REPO/RESTORE.md" "$DEST/RESTORE.md"
ln -sfn "snapshots/$STAMP" "$DEST/latest"

# =============================================================================
# Prune: keep the KEEP newest snapshots, delete older
# =============================================================================
n=$(ls -1d "$SNAP_ROOT"/*/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$n" -gt "$KEEP" ]; then
  echo "Pruning $((n - KEEP)) old snapshot(s) (keeping $KEEP)..."
  ls -1d "$SNAP_ROOT"/*/ | sort | head -n "$((n - KEEP))" | while IFS= read -r d; do
    rm -rf "$d"
    echo "  pruned $(basename "${d%/}")"
  done
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=== Done ==="
echo "New snapshot : $SNAP"
echo "  repo       : $(du -sh "$SNAP/repo" 2>/dev/null | cut -f1)"
echo "  secrets    : $(du -sh "$SPARSE" 2>/dev/null | cut -f1)"
echo "Retained     :"
ls -1d "$SNAP_ROOT"/*/ 2>/dev/null | sort | while IFS= read -r d; do echo "  $(basename "${d%/}")"; done
echo ""
echo "WARNING: tokens hard-coded in ~/.zshrc are NOT in the encrypted image —"
echo "  .zshrc is a tracked dotfile and lives plaintext in repo/. Keep real"
echo "  secrets out of .zshrc; use .npmrc/.netrc (encrypted) or 1Password."
