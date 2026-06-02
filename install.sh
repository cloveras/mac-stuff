#!/usr/bin/env bash
# New Mac setup script
# Run this once after a fresh macOS install.

set -e

echo "=== Mac Setup ==="

# =============================================================================
# Restore from backups (optional, interactive)
# =============================================================================
# Runs first so restored SSH keys are in place before clone-repos.sh clones
# private repos over SSH. Skipped entirely on a non-interactive run.
USB_BACKUP="/Volumes/CL256GB/mac-backup/latest"

ask() {  # ask "Question?" -> exit 0 on yes
  local reply
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

restore_secrets_from_usb() {
  if [ ! -d "$USB_BACKUP" ]; then
    echo "  USB backup not found at $USB_BACKUP — skipping."
    echo "  (Plug in the drive and grant the terminal Full Disk Access, then re-run.)"
    return 0
  fi
  local mnt src
  mnt="$(mktemp -d /tmp/mac-secrets.XXXXXX)"
  echo "  Mounting encrypted secrets image (enter passphrase from 1Password)..."
  if ! hdiutil attach "$USB_BACKUP/secrets.sparseimage" -nobrowse -mountpoint "$mnt" >/dev/null; then
    echo "  Could not mount image (wrong passphrase?) — skipping."
    rmdir "$mnt" 2>/dev/null || true
    return 0
  fi
  src="$mnt"

  # --- SSH ---
  if [ -d "$src/ssh" ]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    rsync -a "$src/ssh/" ~/.ssh/
    chmod 600 ~/.ssh/id_* 2>/dev/null || true
    chmod 644 ~/.ssh/*.pub ~/.ssh/known_hosts 2>/dev/null || true
    echo "  Restored ~/.ssh"
  fi
  # --- Git + shell identity ---
  [ -f "$src/git/.gitconfig" ] && { cp "$src/git/.gitconfig" ~/.gitconfig; echo "  Restored ~/.gitconfig"; }
  [ -f "$src/git/.netrc" ]     && { cp "$src/git/.netrc" ~/.netrc; chmod 600 ~/.netrc; echo "  Restored ~/.netrc"; }
  [ -f "$src/git/.npmrc" ]     && { cp "$src/git/.npmrc" ~/.npmrc; echo "  Restored ~/.npmrc"; }
  # --- Cloud CLI creds ---
  [ -d "$src/cloud/aws" ]   && { mkdir -p ~/.aws;       rsync -a "$src/cloud/aws/" ~/.aws/; echo "  Restored ~/.aws"; }
  [ -d "$src/cloud/azure" ] && { mkdir -p ~/.azure;     rsync -a "$src/cloud/azure/" ~/.azure/; echo "  Restored ~/.azure"; }
  [ -d "$src/cloud/gh" ]    && { mkdir -p ~/.config/gh; rsync -a "$src/cloud/gh/" ~/.config/gh/; echo "  Restored ~/.config/gh"; }
  [ -f "$src/cloud/docker/config.json" ] && { mkdir -p ~/.docker; cp "$src/cloud/docker/config.json" ~/.docker/; echo "  Restored ~/.docker/config.json"; }
  # --- AI tooling auth (may be stale; re-auth if rejected) ---
  [ -f "$src/ai/.claude.json" ] && { cp "$src/ai/.claude.json" ~/.claude.json; echo "  Restored ~/.claude.json"; }
  [ -d "$src/ai/mcp-auth" ] && { mkdir -p ~/.mcp-auth; rsync -a "$src/ai/mcp-auth/" ~/.mcp-auth/; echo "  Restored ~/.mcp-auth"; }
  [ -d "$src/ai/codex" ]    && { mkdir -p ~/.codex;    rsync -a "$src/ai/codex/" ~/.codex/; echo "  Restored ~/.codex"; }
  [ -d "$src/ai/gemini" ]   && { mkdir -p ~/.gemini;   rsync -a "$src/ai/gemini/" ~/.gemini/; echo "  Restored ~/.gemini"; }

  hdiutil detach "$mnt" >/dev/null 2>&1 || true
  rmdir "$mnt" 2>/dev/null || true
  echo "  Secrets restored. AI/cloud tokens may be stale — re-auth if a CLI complains."
}

restore_from_time_machine() {
  echo "  Time Machine restore is interactive — install.sh can't pick files for you."
  echo "  Known destinations:"
  tmutil destinationinfo 2>/dev/null | sed 's/^/    /' || echo "    (none configured)"
  echo "  Options:"
  echo "    • Whole-account migration: open Migration Assistant, choose the TM disk."
  echo "    • Single files/folders: enter Time Machine from the menu-bar clock icon."
  if ask "  Open Migration Assistant now?"; then
    open -a "Migration Assistant" 2>/dev/null || echo "  Could not open Migration Assistant."
  fi
}

if [ -t 0 ]; then
  echo ""
  echo "--- Restore from backups (optional) ---"
  if ask "Restore settings & secrets from the USB backup (SSH keys, git, cloud, AI)?"; then
    restore_secrets_from_usb
  fi
  if ask "Restore files from a Time Machine backup?"; then
    restore_from_time_machine
  fi
  echo ""
fi

# =============================================================================
# Homebrew
# =============================================================================
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing brew packages..."
brew bundle install --file="$(dirname "$0")/Brewfile"

# =============================================================================
# npm globals
# =============================================================================
echo "Installing global npm packages..."
while IFS= read -r pkg; do
  [[ -z "$pkg" ]] && continue
  npm install -g "$pkg"
done < "$(dirname "$0")/npm-globals.txt"

# =============================================================================
# Dev folder and repos
# =============================================================================
echo "Cloning repos into ~/Dev..."
bash "$(dirname "$0")/clone-repos.sh"

# =============================================================================
# Dotfiles
# =============================================================================
echo "Symlinking dotfiles..."
bash "$(dirname "$0")/symlink.sh"

# =============================================================================
# macOS preferences
# =============================================================================
echo "Applying macOS preferences..."
bash "$(dirname "$0")/macos-prefs.sh"

# =============================================================================
# Default shell
# =============================================================================
echo "Setting zsh as default shell..."
chsh -s /bin/zsh

echo ""
echo "All done! Restart your Mac to make sure everything takes effect."
